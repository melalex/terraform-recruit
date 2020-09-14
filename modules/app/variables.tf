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

variable "app_port" {
  description = "The port on which app receive traffic."
  type = number
  default = 8080
}

variable "app_protocol" {
  description = "The protocol to use for routing traffic to the app. Should be one of 'TCP', 'TLS', 'UDP', 'TCP_UDP', 'HTTP' or 'HTTPS'."
  type = string
  default = "HTTP"
}