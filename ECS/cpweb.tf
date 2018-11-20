data "template_file" "cpweb" {
  template = "${file("${path.module}/templates/cpweb_ecs_task.tpl")}"

  vars {
    cpweb_apikey = "${var.cpweb_apikey}"
    cpweb_image = "${var.cpweb_image}"
    opsvr_url = "https://${aws_route53_record.opsvr.name}:8088/api"
  }
}

# data "aws_ecs_task_definition" "cpweb" {
#   task_definition = "${aws_ecs_task_definition.cpweb.family}"
# }

resource "aws_ecs_task_definition" "cpweb" {
  family = "cpweb-${var.cluster_name}"
  container_definitions = "${data.template_file.cpweb.rendered}"
}

resource "aws_ecs_service" "cpweb" {
  name          = "cpweb-${var.cluster_name}-web"
  cluster       = "${aws_ecs_cluster.ecs_cluster.id}"
  desired_count = 2

  # Track the latest ACTIVE revision
  task_definition = "${aws_ecs_task_definition.cpweb.family}"

  load_balancer {
    elb_name = "cpweb-${var.cluster_name}-elb"
    container_name = "node"
    container_port = "7777"
  }

  depends_on = [
    "aws_elb.cpweb"
  ]
}

resource "aws_route53_record" "cpweb" {
  zone_id = "Z2MTCF61RL4A9K"
  name    = "${var.cluster_name}-web.chefsplateops.net"
  type    = "A"

  alias {
    name                   = "${aws_elb.cpweb.dns_name}"
    zone_id                = "${aws_elb.cpweb.zone_id}"
    evaluate_target_health = true
  }
}
