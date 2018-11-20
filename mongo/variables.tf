variable "iam_instance_role" {
  description = "IAM Roles"
}

variable "expire_on" {
  description = "When the provisioned instances should expire"
  default = "2029-01-01"
}

variable "key_name" {
  description = "SSH key name in your AWS account for AWS instances."
}

# variable "key_path" {
#   description = "Path to the private key specified by key_name."
#   default = "~/.ssh/cp-devops.pem"
# }

variable "tag_name" {
  description = "The AWS tag name."
}

variable "region" {
  description = "The AWS region"
}

variable "replset" {
  description = "The replica set name"
}

variable "servers" {
  description = "The number of servers"
}

variable "vpc_id" {
  description = "The number of servers"

}

variable "public_subnet_ids" {
  description = "Public Subnets where Mongo will exist"
  type = "list"
}

variable "cluster_name" {
  description = "Name of the cluster from branch - build"
  type = "string"
}

variable "private_subnet_ids" {
  type = "list"
}
variable "vpc_cidr" {
  type = "list"
}
