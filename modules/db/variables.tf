variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
  type = string
}

variable "db_user" {
  description = "Username for the master DB user."
  type = string
}

variable "db_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file."
  type = string
}

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