terraform {
  backend "s3" {
    region = var.aws_region
    bucket = "s3-terraform-interview"
    key = "melalex/terraform-recruit/cluster.tfstate"
  }
}
