output "asg_id" {
  value = "${aws_autoscaling_group.asg.id}"
}

output "asg_arn" {
  value = "${aws_autoscaling_group.asg.arn}"
}

output "asg_launch_configuration" {
  value = "${aws_autoscaling_group.asg.launch_configuration}"
}
