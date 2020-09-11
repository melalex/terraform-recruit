terraform {
  backend "s3" {
    region = var.aws_region
    bucket = "s3-terraform-interview"
    key = "melalex/terraform-recruit/cluster.tfstate"
  }
}

provider "aws" {
  version = "~> 3.0"
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

locals {
  availability_zone = data.aws_availability_zones.this.names[0]

  project_name = "terraform-recruit"
  owner = "melalex"
}