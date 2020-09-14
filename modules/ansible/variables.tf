variable "app_eip_list" {
  description = "IP address of AWS instance"
  type = list(string)
}

variable "db_user" {
  description = "Username for the master DB user."
  type = string
}

variable "db_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file."
  type = string
}

variable "db_host" {
  description = "The hostname of the RDS instance."
  type = string
}

variable "db_port" {
  description = "The database port."
  type = string
}

variable "app_ssh_private_key_pem" {
  description = "The private key data in PEM format."
  type = string
}

variable "app_ssh_public_key_pem" {
  description = "The public key data in PEM format."
  type = string
}

variable "flyway_folder" {
  description = "Path to folder with db migrations."
  type = string
}