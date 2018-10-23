variable "s3_region" {
  type    = "string"
  default = "us-east-1"
}

// Required:
variable "cluster_name" {
  type = "string"
}

variable "ecs_ami_id" {
  type = "string"
  default = "ami-20ff515a"
}

variable "ec2_instance_type" {
  type = "string"
  default = "t2.medium"
}

variable "lc_ecs_ami_id" {
  type = "string"
  description = "Selecting specific AMI ID for ECS Cluster"
}

variable "aws_IamInstanceProfile" {
  type = "string"
  description = "Policies allowed in the EC2 instance"
}
