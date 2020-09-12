variable "db_user" {}
variable "db_password" {}

variable "db_port" {
  description = "The port on which the DB accepts connections."
  default = 3306
}

variable "project_name" {
  description = "Name of the project."
  type = string
}

variable "owner" {
  description = "Name of the project owner."
  type = string
}

variable "vpc_id" {
  description = "The VPC ID."
  type = string
}

variable "subnet_ids" {
  description = "The VPC Subnet IDs to launch in."
  type = list(string)
}