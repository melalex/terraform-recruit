terraform {
  backend "s3" {
    region = "eu-west-3"
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
  project_name = "terraform-recruit"
  owner = "melalex"
}

data "aws_availability_zones" "this" {}

module "vpc" {
  source = "./modules/vpc"

  owner = local.owner
  project_name = local.project_name

  azs = data.aws_availability_zones.this.names

  public_subnets = [
    "10.0.0.0/24"
  ]

  private_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

module "app" {
  source = "./modules/app"

  owner = local.owner
  project_name = local.project_name

  subnet_id = module.vpc.public_subnet_ids[0]
  vpc_id = module.vpc.this_vpc_id
}

module "db" {
  source = "./modules/db"

  owner = local.owner
  project_name = local.project_name

  db_user = var.db_user
  db_password = var.db_password

  subnet_ids = module.vpc.private_subnet_ids
  vpc_id = module.vpc.this_vpc_id
}