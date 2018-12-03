/*
*  Create ECS Task Definition - Backend Services
*/
# Simply specify the family to find the latest ACTIVE revision in that family.
data "template_file" "opsvrweb" {
  template = "${file("${path.module}/templates/opsvr_ecs_task.tpl")}"

  vars {
    opsvr_app_key = "${var.opsvr_app_key}"
    mailtrap_password = "${var.mailtrap_password}"
    mailtrap_username = "${var.mailtrap_username}"
    mongo_audit_dsn = "${var.mongo_audit_dsn}"
    mongo_dsn = "${var.mongo_dsn}"
    opsvr_image = "${var.opsvr_image}"
  }
}

data "aws_ecs_task_definition" "opsvrweb" {
  task_definition = "${aws_ecs_task_definition.opsvrweb.family}"
}

resource "aws_ecs_task_definition" "opsvrweb" {
  family = "opsvr-${var.cluster_name}-web"
  container_definitions = "${data.template_file.opsvrweb.rendered}"
}

resource "aws_ecs_service" "opsvrweb" {
  name          = "opsvr-${var.cluster_name}-web"
  cluster       = "${aws_ecs_cluster.ecs_cluster.id}"
  desired_count = 2

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.opsvrweb.family}:${max("${aws_ecs_task_definition.opsvrweb.revision}", "${data.aws_ecs_task_definition.opsvrweb.revision}")}"

  load_balancer {
    elb_name = "opsvr-${var.cluster_name}-elb"
    container_name = "web"
    container_port = "8088"
  }

  depends_on = [
    "aws_elb.opsvr"
  ]
}


#
# Application AutoScaling resources
#
resource "aws_appautoscaling_target" "opsvrweb" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.opsvrweb.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = "1"
  max_capacity       = "6"

  depends_on = [
    "aws_ecs_service.opsvrweb",
  ]
}

resource "aws_appautoscaling_policy" "opsvrwebUp" {
  name               = "${var.cluster_name}appScalingPolicyOPSVRWebScaleUp"
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.opsvrweb.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = "120"
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [
    "aws_appautoscaling_target.opsvrweb",
  ]
}

resource "aws_cloudwatch_metric_alarm" "opsvr_service_high_cpu" {
  alarm_name          = "${var.cluster_name}OPSVRWebScaleUp"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions {
    ClusterName = "${var.cluster_name}"
    ServiceName = "${aws_ecs_service.opsvrweb.name}"
  }

  alarm_description = "This metric monitors ecs cpu utilization"
  alarm_actions = ["${aws_appautoscaling_policy.opsvrwebUp.arn}"]
}

resource "aws_route53_record" "opsvr" {
  zone_id = "Z2MTCF61RL4A9K"
  name    = "${var.cluster_name}-api.chefsplateops.net"
  type    = "A"

  alias {
    name                   = "${aws_elb.opsvr.dns_name}"
    zone_id                = "${aws_elb.opsvr.zone_id}"
    evaluate_target_health = true
  }
}
