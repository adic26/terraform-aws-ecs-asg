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
data "aws_ecs_task_definition" "opsvrweb" {
  task_definition = "${aws_ecs_task_definition.opsvrweb.family}"
}

resource "aws_ecs_task_definition" "opsvrweb" {
  family = "opsvr-${var.cluster_name}-web"

  container_definitions = <<EOF
[
  {
    "memory": 800,
    "logConfiguration": {
      "logDriver": "syslog",
      "options": {
        "syslog-address": "udp://logs6.papertrailapp.com:13812",
        "tag": "{{.Name}}"
      }
    },
    "environment": [{
        "name": "APP_DEBUG",
        "value": "1"
      },
      {
        "name": "APP_ENV",
        "value": "sit"
      },
      {
        "name": "APP_KEY",
        "value": "${var.opsvr_app_key}"
      },
      {
        "name": "APP_LOG",
        "value": "syslog"
      },
      {
        "name": "AUDIT_DEBUG",
        "value": "0"
      },
      {
        "name": "AUDIT_DIRECT_DB_WRITES",
        "value": "0"
      },
      {
        "name": "AUDIT_KINESIS_REGION",
        "value": "us-east-1"
      },
      {
        "name": "AUDIT_KINESIS_VERSION",
        "value": "2013-12-02"
      },
      {
        "name": "AUDIT_SHARD_BUCKETS",
        "value": "5"
      },
      {
        "name": "AUDIT_STATE",
        "value": "0"
      },
      {
        "name": "ES_DSN1",
        "value": "http://172.31.3.106:9200"
      },
      {
        "name": "ES_DSN2",
        "value": ""
      },
      {
        "name": "INTERNAL_AUTH_APP",
        "value": ""
      },
      {
        "name": "INTERNAL_AUTH_KEY",
        "value": ""
      },
      {
        "name": "INTERNAL_AUTH_SIG",
        "value": ""
      },
      {
        "name": "LEGACY_DB_HOST",
        "value": ""
      },
      {
        "name": "LEGACY_DB_NAME",
        "value": ""
      },
      {
        "name": "LEGACY_DB_PASS",
        "value": ""
      },
      {
        "name": "LEGACY_DB_USER",
        "value": ""
      },
      {
        "name": "MAIL_HOST",
        "value": "smtp.mailtrap.io"
      },
      {
        "name": "MAIL_PASSWORD",
        "value": "${var.mailtrap_password}"
      },
      {
        "name": "MAIL_PORT",
        "value": "2525"
      },
      {
        "name": "MAIL_USERNAME",
        "value": "${var.mailtrap_username}"
      },
      {
        "name": "MANDRILL_SECRET",
        "value": ""
      },
      {
        "name": "MONGO_AUDIT_DB_NAME",
        "value": "audit-trail"
      },
      {
        "name": "MONGO_AUDIT_DSN",
        "value": "${var.mongo_audit_dsn}"
      },
      {
        "name": "MONGO_DB_NAME",
        "value": "sit-opsserver"
      },
      {
        "name": "MONGO_DSN",
        "value": "${var.mongo_dsn}"
      },
      {
        "name": "NEWRELIC_APP",
        "value": "Ops Server [sit]"
      },
      {
        "name": "QUEUE_DRIVER",
        "value": "mongodb"
      },
      {
        "name": "QUEUE_ENV",
        "value": "sit"
      },
      {
        "name": "REDIS_DSN",
        "value": "tcp://172.31.3.106:6379"
      },
      {
        "name": "SYSLOG_HOST",
        "value": "logs6.papertrailapp.com"
      },
      {
        "name": "SYSLOG_PORT",
        "value": "22002"
      }
    ],
    "portMappings": [{
      "hostPort": 8088,
      "protocol": "tcp",
      "containerPort": 8088
    }],
    "image": "${var.opsvr_image}",
    "name": "web"
  }
]
EOF
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
