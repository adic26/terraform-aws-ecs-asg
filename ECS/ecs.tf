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

# Create a new load balancer
resource "aws_elb" "opsvr" {
  name               = "opsvr-${var.cluster_name}-elb"
  # availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  subnets            = ["${var.private_subnet_ids}"]
  security_groups    = ["${aws_security_group.lb_opsvr.id}"]
  internal           = true

  listener {
    instance_port      = 8088
    instance_protocol  = "http"
    lb_port            = 8088
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-east-1:918758342401:certificate/55fa4440-3799-425f-8da5-cc450d673755"
  }

  cross_zone_load_balancing = true

  tags {
    Name = "elb-${var.cluster_name}"
  }
}

resource "aws_security_group" "lb_opsvr" {
  name        = "opsvr-elb-sg"
  description = "Security Group Backend Load Balancer"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "opsvr_allow_only_vpc" {
  type              = "ingress"
  from_port         = 8088
  to_port           = 8088
  protocol          = "tcp"
  cidr_blocks       = ["${var.vpc_cidr}"]
  security_group_id = "${aws_security_group.lb_opsvr.id}"
}

resource "aws_security_group_rule" "opsvr_allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb_opsvr.id}"
}



resource "aws_elb" "cpweb" {
  name               = "cpweb-${var.cluster_name}-elb"
  # availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  subnets            = ["${var.public_subnet_ids}"]
  security_groups    = ["${aws_security_group.lb_cpweb.id}"]
  internal           = false

  listener = [{
      instance_port      = 7777
      instance_protocol  = "http"
      lb_port            = 80
      lb_protocol        = "http"
    },
    {
      instance_port      = 7777
      instance_protocol  = "http"
      lb_port            = 443
      lb_protocol        = "https"
      ssl_certificate_id = "arn:aws:acm:us-east-1:918758342401:certificate/55fa4440-3799-425f-8da5-cc450d673755"
    }
  ]

  cross_zone_load_balancing = true

  tags {
    Name = "elb-${var.cluster_name}"
  }
}

resource "aws_security_group" "lb_cpweb" {
  name        = "cpweb-elb-sg"
  description = "Security Group Backend Load Balancer"
  vpc_id      = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cpweb_allow_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb_cpweb.id}"
}

resource "aws_security_group_rule" "cpweb_allow_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb_cpweb.id}"
}

resource "aws_security_group_rule" "cpweb_allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.lb_cpweb.id}"
}
