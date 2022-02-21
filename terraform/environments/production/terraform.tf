terraform {
  backend "s3" {
    bucket = "atikaroom-tf-states"
    key    = "web/production/eu-west-1/terraform.tfstate"
    region = "eu-west-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.2.0"
    }
  }
}
