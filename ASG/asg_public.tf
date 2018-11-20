/*
 * Create Launch Configuration
 */
resource "aws_launch_configuration" "public_lc" {
  image_id             = "${var.aws_ami_id}"
  name_prefix          = "${var.cluster_name}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${var.aws_IamInstanceProfile}"
  security_groups      = ["${aws_security_group.public_ec2s.id}"]
  user_data            = "${var.user_data != "false" ? var.user_data : data.template_file.user_data.rendered}"
  key_name             = "${var.ssh_key_name}"

  root_block_device {
    volume_size = "${var.root_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "public_ec2s" {
  name = "web2-ec2-sg-1"
  description = "Security Group Frontend Load Balancer"
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_security_group_rule" "public_allow_all_http" {
  type              = "ingress"
  from_port         = 7777
  to_port           = 7777
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.public_ec2s.id}"
}

resource "aws_security_group_rule" "public_allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.public_ec2s.id}"
}

resource "aws_security_group_rule" "public_allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.public_ec2s.id}"
}

/*
 * Create Auto-Scaling Group
 */
resource "aws_autoscaling_group" "asg_public" {
  name                      = "public-${var.cluster_name}"
  vpc_zone_identifier       = ["${var.public_subnet_ids}"]
  min_size                  = "0"
  max_size                  = "${var.max_size}"
  desired_capacity          = "2"
  health_check_type         = "${var.health_check_type}"
  health_check_grace_period = "${var.health_check_grace_period}"
  default_cooldown          = "${var.default_cooldown}"
  termination_policies      = ["${var.termination_policies}"]
  launch_configuration      = "${aws_launch_configuration.public_lc.id}"

  tags = ["${concat(
    list(
      map("key", "Name", "value", var.cluster_name, "propagate_at_launch", true)
    ),
    var.tags
  )}"]

  protect_from_scale_in = "${var.protect_from_scale_in}"

  lifecycle {
    create_before_destroy = true
  }
}

/*
 * Create autoscaling policies
 */
resource "aws_autoscaling_policy" "public_up" {
  name                   = "${var.cluster_name}-scaleUp"
  scaling_adjustment     = "${var.scaling_adjustment_up}"
  adjustment_type        = "${var.adjustment_type}"
  cooldown               = "${var.policy_cooldown}"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  count                  = "${var.alarm_actions_enabled ? 1 : 0}"
}

resource "aws_autoscaling_policy" "public_down" {
  name                   = "${var.cluster_name}-scaleDown"
  scaling_adjustment     = "${var.scaling_adjustment_down}"
  adjustment_type        = "${var.adjustment_type}"
  cooldown               = "${var.policy_cooldown}"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  count                  = "${var.alarm_actions_enabled ? 1 : 0}"
}

/*
 * Create CloudWatch alarms to trigger scaling of ASG
 */
resource "aws_cloudwatch_metric_alarm" "public_scaleUp" {
  alarm_name          = "${var.cluster_name}-scaleUp"
  alarm_description   = "ECS cluster scaling metric above threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  metric_name         = "${var.scaling_metric_name}"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  period              = "${var.alarm_period}"
  threshold           = "${var.alarm_threshold_up}"
  actions_enabled     = "${var.alarm_actions_enabled}"
  count               = "${var.alarm_actions_enabled ? 1 : 0}"
  alarm_actions       = ["${aws_autoscaling_policy.up.arn}"]

  dimensions {
    ClusterName = "${var.cluster_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "public_scaleDown" {
  alarm_name          = "${var.cluster_name}-scaleDown"
  alarm_description   = "ECS cluster scaling metric under threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "${var.evaluation_periods}"
  metric_name         = "${var.scaling_metric_name}"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  period              = "${var.alarm_period}"
  threshold           = "${var.alarm_threshold_down}"
  actions_enabled     = "${var.alarm_actions_enabled}"
  count               = "${var.alarm_actions_enabled ? 1 : 0}"
  alarm_actions       = ["${aws_autoscaling_policy.down.arn}"]

  dimensions {
    ClusterName = "${var.cluster_name}"
  }
}
