variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "db_user" {}
variable "db_password" {}

variable "aws_region" {
  description = "EC2 Region for the VPC."
  default = "eu-west-3"
}

variable "db_port" {
  description = "The port on which the DB accepts connections."
  default = 3306
}
