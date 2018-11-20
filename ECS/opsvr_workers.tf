module "allocation" {
  source = "./module.terraform-opsvr-workers"
  cluster_name = "${var.cluster_name}"
  cluster_id = "${aws_ecs_cluster.ecs_cluster.id}"
  fam_worker_type = "worker-general-allocation"
  queue_worker_type = "opsvr-${var.cluster_name}-allocation"
  worker_type = "allocation"
  opsvr_app_key = "${var.opsvr_app_key}"
  mailtrap_password = "${var.mailtrap_password}"
  mailtrap_username = "${var.mailtrap_username}"
  mongo_audit_dsn = "${var.mongo_audit_dsn}"
  mongo_dsn = "${var.mongo_dsn}"
  opsvr_image = "${var.opsvr_image}"
}

module "autodel" {
  source = "./module.terraform-opsvr-workers"
  cluster_name = "${var.cluster_name}"
  cluster_id = "${aws_ecs_cluster.ecs_cluster.id}"
  fam_worker_type = "worker-autodel"
  queue_worker_type = "opsvr-${var.cluster_name}-autodelivery"
  worker_type = "autodel"
  opsvr_app_key = "${var.opsvr_app_key}"
  mailtrap_password = "${var.mailtrap_password}"
  mailtrap_username = "${var.mailtrap_username}"
  mongo_audit_dsn = "${var.mongo_audit_dsn}"
  mongo_dsn = "${var.mongo_dsn}"
  opsvr_image = "${var.opsvr_image}"
}

module "high" {
  source = "./module.terraform-opsvr-workers"
  cluster_name = "${var.cluster_name}"
  cluster_id = "${aws_ecs_cluster.ecs_cluster.id}"
  queue_worker_type = "opsvr-${var.cluster_name}-high-priority"
  fam_worker_type = "worker-general-high"
  worker_type = "high"
  opsvr_app_key = "${var.opsvr_app_key}"
  mailtrap_password = "${var.mailtrap_password}"
  mailtrap_username = "${var.mailtrap_username}"
  mongo_audit_dsn = "${var.mongo_audit_dsn}"
  mongo_dsn = "${var.mongo_dsn}"
  opsvr_image = "${var.opsvr_image}"
}

module "med-low" {
  source = "./module.terraform-opsvr-workers"
  cluster_name = "${var.cluster_name}"
  cluster_id = "${aws_ecs_cluster.ecs_cluster.id}"
  queue_worker_type = "opsvr-${var.cluster_name}-med-priority,opsvr-${var.cluster_name}-low-priority"
  fam_worker_type = "worker-general-med-low"
  worker_type = "med-low"
  opsvr_app_key = "${var.opsvr_app_key}"
  mailtrap_password = "${var.mailtrap_password}"
  mailtrap_username = "${var.mailtrap_username}"
  mongo_audit_dsn = "${var.mongo_audit_dsn}"
  mongo_dsn = "${var.mongo_dsn}"
  opsvr_image = "${var.opsvr_image}"
}
