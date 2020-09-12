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

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in."
  type = string
}