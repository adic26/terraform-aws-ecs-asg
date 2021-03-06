variable "cluster_name" {
  type = "string"
}
variable "private_subnet_ids" {
  type = "list"
}
variable "vpc_cidr" {
  type = "list"
}
variable "public_subnet_ids" {
  type = "list"
}
variable "aws_ami_id" {
  type = "string"
}
variable "aws_IamInstanceProfile" {
  type = "string"
  description = "Policies allowed in the EC2 instance"
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
variable "vpc_id" {
  type = "string"
}


variable "scaling_adjustment_up" {
  default     = "1"
  description = "How many instances to scale up by when triggered"
}

variable "scaling_adjustment_down" {
  default     = "-1"
  description = "How many instances to scale down by when triggered"
}

variable "scaling_metric_name" {
  default     = "CPUReservation"
  description = "Options: CPUReservation or MemoryReservation"
}

variable "adjustment_type" {
  default     = "ChangeInCapacity"
  description = "Options: ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity"
}

variable "policy_cooldown" {
  default     = 300
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
}

variable "evaluation_periods" {
  default     = "2"
  description = "The number of periods over which data is compared to the specified threshold."
}

variable "alarm_period" {
  default     = "120"
  description = "The period in seconds over which the specified statistic is applied."
}

variable "alarm_threshold_up" {
  default     = "60"
  description = "The value against which the specified statistic is compared."
}

variable "alarm_threshold_down" {
  default     = "40"
  description = "The value against which the specified statistic is compared."
}

variable "alarm_actions_enabled" {
  default = true
}

variable "ssh_key_name" {
  default     = "cp-devops"
  description = "Name of SSH key pair to use as default (ec2-user) user key"
}

variable "instance_type" {
  default     = "t2.medium"
  description = "See: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#AvailableInstanceTypes"
}

variable "user_data" {
  description = "Bash code for inclusion as user_data on instances. By default contains minimum for registering with ECS cluster"
  default     = "false"
}

variable "root_volume_size" {
  default = "8"
}

variable "min_size" {
  default = "4"
}

variable "max_size" {
  default = "5"
}

variable "health_check_type" {
  default = "EC2"
}

variable "health_check_grace_period" {
  default = "300"
}

variable "default_cooldown" {
  default = "30"
}

variable "termination_policies" {
  type        = "list"
  default     = ["Default"]
  description = "The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default."
}

variable "protect_from_scale_in" {
  default = false
}

variable "tags" {
  type        = "list"
  description = "List of maps with keys: 'key', 'value', and 'propagate_at_launch'"

  default = [
    {
      key                 = "created_by"
      value               = "terraform"
      propagate_at_launch = true
    },
  ]
}
