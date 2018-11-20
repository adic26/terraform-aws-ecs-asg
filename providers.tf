provider "aws" {
  region = "${var.s3_region}"

  version = "1.41"
}

terraform {
  required_version = ">= 0.11.10"

  backend "s3" {
    bucket = "cpweb-tf-state-backend"
    key = "test/ecs-asg-mongodb"
    region = "us-east-1"
    encrypt = "true"
  }
}
