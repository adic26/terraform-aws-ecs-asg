module "ecs_cluster" {
  source = "./ECS"

  cluster_name              = "${var.cluster_name}"
  private_subnet_ids        = ["${var.private_subnet_ids}"]
  vpc_id                    = "${var.vpc_id}"
  vpc_cidr                  = ["${var.vpc_cidr}"]
  public_subnet_ids         = ["${var.public_subnet_ids}"]
  opsvr_app_key             = "${var.opsvr_app_key}"
  mailtrap_password         = "${var.mailtrap_password}"
  mailtrap_username         = "${var.mailtrap_username}"
  mongo_audit_dsn           = "${var.mongo_audit_dsn}"
  mongo_dsn                 = "mongodb://${var.replset}/${join(":27017,", module.MONGO.mongo_private_ips)}:27017"
  opsvr_image               = "${var.opsvr_image}"
  aws_IamInstanceProfile    = "${var.aws_IamInstanceProfile}"
  private_registry          = "${var.private_registry}"
  private_registry_username = "${var.private_registry_username}"
  private_registry_password = "${var.private_registry_password}"
  cpweb_apikey              = "${var.cpweb_apikey}"
  cpweb_image               = "${var.cpweb_image}"
}

module "ASG" {
  source = "./ASG"

  cluster_name              = "${var.cluster_name}"
  vpc_id                    = "${var.vpc_id}"
  aws_ami_id                = "${module.ecs_cluster.ecs_ami_id}"
  private_subnet_ids        = ["${var.private_subnet_ids}"]
  vpc_cidr                  = ["${var.vpc_cidr}"]
  public_subnet_ids         = ["${var.public_subnet_ids}"]
  aws_IamInstanceProfile    = "${var.aws_IamInstanceProfile}"
  private_registry          = "${var.private_registry}"
  private_registry_username = "${var.private_registry_username}"
  private_registry_password = "${var.private_registry_password}"
}

module "MONGO" {
  source = "./mongo"

  cluster_name       = "${var.cluster_name}"
  vpc_id             = "${var.vpc_id}"
  vpc_cidr           = ["${var.vpc_cidr}"]
  private_subnet_ids = ["${var.private_subnet_ids}"]
  public_subnet_ids  = ["${var.public_subnet_ids}"]
  iam_instance_role  = "${var.aws_IamInstanceProfile}"
  key_name           = "${var.key_name}"
  tag_name           = "${var.tag_name}"
  replset            = "${var.replset}"
  servers            = "${var.servers}"
  region             = "${var.s3_region}"
}
