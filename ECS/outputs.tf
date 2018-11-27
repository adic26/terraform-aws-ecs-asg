output "ecs_ami_id" {
  value = "${data.aws_ami.ecs_ami.id}"
}

output "ecs_cluster_id" {
  value = "${aws_ecs_cluster.ecs_cluster.id}"
}

output "ecs_cluster_name" {
  value = "${aws_ecs_cluster.ecs_cluster.name}"
}

output "elb_dns_name" {
  value = "${aws_elb.opsvr.dns_name}"
}

output "route53_frontend_url" {
  value = "${aws_route53_record.cpweb.name}"
}

output "route53_backend_url" {
  value = "${aws_route53_record.opsvr.name}"
}

output "opsvr_worker_autodel" {
  value = "${module.autodel.queue_worker_type}"
}
