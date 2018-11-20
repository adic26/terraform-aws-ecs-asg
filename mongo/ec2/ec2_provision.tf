
provider "aws" {
  region = "${var.region}"
}

data "aws_subnet" "vpc" {
  count = "${var.zones}"
  id = "${var.subnet_ids[count.index]}"
}

resource "aws_ebs_volume" "data-volumes" {
  availability_zone = "${element(data.aws_subnet.vpc.*.availability_zone, count.index % var.zones)}"
  size              = "${var.volume_size}"
  type              = "${var.volume_type}"
  iops              = "${var.volume_iops}"
  count             = "${var.servers}"
  tags {
    Name       = "${var.tag_name}-${count.index}"
    owner      = "${var.owner}"
  }
}

resource "aws_instance" "cluster" {
  ami                         = "${var.ami_id}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${var.security_group}"]
  subnet_id                   = "${element(data.aws_subnet.vpc.*.id, count.index % var.zones)}"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${var.iam_role}"
  count                       = "${var.servers}"
  # wait_for_fulfillment        = true
  # spot_price                  = "${var.spot_price}"
  associate_public_ip_address = true

  tags {
    Name       = "${var.tag_name}-${count.index}"
    owner      = "${var.owner}"
    expire-on  = "${var.expire_on}"
  }
}

resource "aws_volume_attachment" "data" {
  device_name       = "/dev/xvdb"
  volume_id         = "${element(aws_ebs_volume.data-volumes.*.id, count.index)}"
  instance_id       = "${element(aws_instance.cluster.*.id, count.index)}"
  skip_destroy      = true
  count             = "${var.servers}"
}

output "public_ips" {
  value = "${aws_instance.cluster.*.public_ip}"
}

output "private_ips" {
  value = "${aws_instance.cluster.*.private_ip}"
}

output "instance_ids" {
  value = "${join("\n", aws_instance.cluster.*.id)}"
}

output "volume_ids" {
  value = "${aws_volume_attachment.data.*.id}"
}
