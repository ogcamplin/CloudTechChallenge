terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "cloudtechchallenge-tfstate"
    key    = "state/terraform.tfstate"
    region = "ap-southeast-2"
    encrypt = true
  }
}