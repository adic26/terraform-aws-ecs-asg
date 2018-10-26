/*
 * Determine most recent ECS optimized AMI
 */
data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

/*
 * Create ECS cluster
 */
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.cluster_name}"
}

/*
 * Create ECS IAM Instance Role and Policy
 */
resource "random_id" "code" {
  byte_length = 4
}

# resource "aws_iam_role" "ecsInstanceRole" {
#   name               = "ecsInstanceRole-${random_id.code.hex}"
#   assume_role_policy = "${var.ecsInstanceRoleAssumeRolePolicy}"
# }
#
# resource "aws_iam_role_policy" "ecsInstanceRolePolicy" {
#   name   = "ecsInstanceRolePolicy-${random_id.code.hex}"
#   role   = "${aws_iam_role.ecsInstanceRole.id}"
#   policy = "${var.ecsInstancerolePolicy}"
# }
#
# /*
#  * Create ECS IAM Service Role and Policy
#  */
# resource "aws_iam_role" "ecsServiceRole" {
#   name               = "ecsServiceRole-${random_id.code.hex}"
#   assume_role_policy = "${var.ecsServiceRoleAssumeRolePolicy}"
# }
#
# resource "aws_iam_role_policy" "ecsServiceRolePolicy" {
#   name   = "ecsServiceRolePolicy-${random_id.code.hex}"
#   role   = "${aws_iam_role.ecsServiceRole.id}"
#   policy = "${var.ecsServiceRolePolicy}"
# }
#
# resource "aws_iam_instance_profile" "ecsInstanceProfile" {
#   name = "ecsInstanceProfile-${random_id.code.hex}"
#   role = "${aws_iam_role.ecsInstanceRole.name}"
# }

/*
 * ECS related variables
 */

// Optional:

# variable "ecsInstanceRoleAssumeRolePolicy" {
#   type = "string"
#
#   default = <<EOF
# {
#   "Version": "2008-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }
#
# variable "ecsInstancerolePolicy" {
#   type = "string"
#
#   default = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ecs:CreateCluster",
#         "ecs:DeregisterContainerInstance",
#         "ecs:DiscoverPollEndpoint",
#         "ecs:Poll",
#         "ecs:RegisterContainerInstance",
#         "ecs:StartTelemetrySession",
#         "ecs:Submit*",
#         "ecr:GetAuthorizationToken",
#         "ecr:BatchCheckLayerAvailability",
#         "ecr:GetDownloadUrlForLayer",
#         "ecr:BatchGetImage",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }
#
# variable "ecsServiceRoleAssumeRolePolicy" {
#   type = "string"
#
#   default = <<EOF
# {
#   "Version": "2008-10-17",
#   "Statement": [
#     {
#       "Sid": "",
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ecs.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }
#
# variable "ecsServiceRolePolicy" {
#   default = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "ec2:AuthorizeSecurityGroupIngress",
#         "ec2:Describe*",
#         "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
#         "elasticloadbalancing:DeregisterTargets",
#         "elasticloadbalancing:Describe*",
#         "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
#         "elasticloadbalancing:RegisterTargets"
#       ],
#       "Resource": "*"
#     }
#   ]
# }
# EOF
# }

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

# Create a new load balancer
resource "aws_elb" "opsvr" {
  name               = "opsvr-${var.cluster_name}-elb"
  availability_zones = ["us-east-1a", "us-east-1c", "us-east-1e", "us-east-1d"]
  security_groups    = ["${var.security_groups}"]


  listener {
    instance_port      = 8088
    instance_protocol  = "http"
    lb_port            = 8088
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-east-1:918758342401:certificate/91b59ced-1cbb-4c78-a0e6-1d57371842e0"
  }

  cross_zone_load_balancing   = true

  tags {
    Name = "elb-${var.cluster_name}"
  }
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
