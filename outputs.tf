output "ecs_ami_id" {
  value = "${module.ecs_cluster.ecs_ami_id}"
}

output "ecs_cluster_id" {
  value = "${module.ecs_cluster.ecs_cluster_id}"
}

output "ecs_cluster_name" {
  value = "${module.ecs_cluster.ecs_cluster_name}"
}

output "elb_dns_name" {
  value = "${module.ecs_cluster.elb_dns_name}"
}

output "route53_frontend_url" {
  value = "${module.ecs_cluster.route53_frontend_url}"
}

output "route53_backend_url" {
  value = "${module.ecs_cluster.route53_backend_url}"
}

output "asg_id" {
  value = "${module.ASG.asg_id}"
}

output "asg_arn" {
  value = "${module.ASG.asg_arn}"
}

output "asg_launch_configuration" {
  value = "${module.ASG.asg_launch_configuration}"
}

output "mongo_public_ips" {
  value = "${module.MONGO.mongo_public_ips}"
}

output "mongo_private_ips" {
  value = "${module.MONGO.mongo_private_ips}"
}

output "mongo_dsn" {
  value = "mongodb://${join(":27017,", module.MONGO.mongo_private_ips)}:27017/?replicaSet=${var.replset}"
}

output "opsvr_worker_autodel" {
  value = "${module.ecs_cluster.opsvr_worker_autodel}"
}





# output "ecs_instance_profile_id" {
#   value = "${aws_iam_instance_profile.ecsInstanceProfile.id}"
# }
#
# output "ecsInstanceRole_arn" {
#   value = "${aws_iam_role.ecsInstanceRole.arn}"
# }
#
# output "ecsServiceRole_arn" {
#   value = "${aws_iam_role.ecsServiceRole.arn}"
# }
