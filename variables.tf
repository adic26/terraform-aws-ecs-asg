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

variable "aws_IamInstanceProfile" {
  type = "string"
  description = "Policies allowed in the EC2 instance"
}

variable "attach_to_load_balancer" {
  type = "string"
  default = "yes"
}

variable "opsvr_image" {
  type = "string"
}

variable "mongo_audit_dsn" {
  type = "string"
}
variable "mongo_dsn" {
  type = "string"
}
variable "opsvr_app_key" {
  type = "string"
}
variable "mailtrap_password" {
  type = "string"
}
variable "mailtrap_username" {
  type = "string"
}

variable "private_registry" {
  type = "string"
}
variable "private_registry_username" {
  type = "string"
}
variable "private_registry_password" {
  type = "string"
}
