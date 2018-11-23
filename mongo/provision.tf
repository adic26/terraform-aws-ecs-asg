module "ec2_ami" {
  source = "./shared"
  region = "${var.region}"
}

module "vpc" {
  source   = "./vpc"
  vpc_id   = "${var.vpc_id}"
  vpc_cidr = "${var.vpc_cidr}"
  region   = "${var.region}"
  owner    = "${var.cluster_name}"
  tag_name = "${var.tag_name}"
}

module "ec2_instances" {
  source         = "./ec2"
  ami_id         = "${module.ec2_ami.ami_id}"
  ami_username   = "${module.ec2_ami.ami_username}"
  iam_role       = "${var.iam_instance_role}"
  region         = "${var.region}"
  owner          = "${var.cluster_name}"
  key_name       = "${var.key_name}"
  key_path       = "${var.key_path}"
  security_group = "${module.vpc.opsmgr_sg}"
  subnet_ids     = ["${var.public_subnet_ids}"]
  zones          = "3"
  expire_on      = "${var.expire_on}"
  tag_name       = "${var.tag_name}-${var.cluster_name}"
  instance_type  = "t2.large"
  volume_size    = "20"
  volume_type    = "gp2"
  volume_iops    = "1000"
  servers        = "${var.servers}"
  spot_price     = "0.05"
}

module "mongodb" {
  source         = "./mongodb"
  region         = "${var.region}"
  key_name       = "${var.key_name}"
  key_path       = "${var.key_path}"
  ami_username   = "${module.ec2_ami.ami_username}"
  replset        = "${var.replset}"
  servers        = "${var.servers}"
  public_ips     = "${module.ec2_instances.public_ips}"
  private_ips    = "${module.ec2_instances.private_ips}"
  volume_ids     = "${module.ec2_instances.volume_ids}"
}

output "mongo_private_ips" {
  value = "${module.ec2_instances.private_ips}"
}

output "mongo_public_ips" {
  value = "${module.ec2_instances.public_ips}"
}
