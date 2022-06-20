terraform {
  backend "s3" {
    bucket = "atikaroom-tf-states"
    key    = "web/testing/eu-west-1/terraform.tfstate"
    region = "eu-west-1"
  }
  required_version = "~> 1.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.19"
    }
  }
}
