variable "region" {
 description = "The region of AWS."
 default     = "us-east-1"
}

variable "owner" {
  description = "Resource owner name for tagging"
}

variable "tag_name" {
  description = "The AWS tag name."
}

variable "vpc_id" {
  description = "ID of current VPC"
}

variable "vpc_cidr" {
  description = "CIDR of current VPC"
  type = "list"
}
