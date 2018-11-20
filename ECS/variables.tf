variable "private_subnet_ids" {
  type = "list"
}
variable "vpc_cidr" {
  type = "list"
}
variable "public_subnet_ids" {
  type = "list"
}
variable "cluster_name" {
  type = "string"
}
variable "vpc_id" {
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
variable "mongo_audit_dsn" {
  type = "string"
}
variable "mongo_dsn" {
  type = "string"
}
variable "opsvr_image" {
  type = "string"
}
variable "aws_IamInstanceProfile" {
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
variable "cpweb_apikey" {
  type = "string"
}
variable "cpweb_image" {
  type = "string"
}
