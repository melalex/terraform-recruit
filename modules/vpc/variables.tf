variable "project_name" {
  description = "Name of the project."
  type = string
}

variable "owner" {
  description = "Name of the project owner."
  type = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC."
  type = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC."
  type = list(string)
}

variable "azs" {
  description = "A list of availability zones names or ids in the region."
  type = list(string)
}

