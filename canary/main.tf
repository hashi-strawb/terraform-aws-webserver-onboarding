# Use https://www.terraform.io/cloud for our State
terraform {
  cloud {
    organization = "fancycorp"

    workspaces {
      tags = ["webserver", "platform:aws"]
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      Name      = "StrawbTest - ${terraform.workspace}"
      Owner     = "lucy.davinhart@hashicorp.com"
      Purpose   = "Terraform TFC Demo Org (FancyCorp)"
      TTL       = "24h"
      Terraform = "true"
      Source    = "https://github.com/FancyCorp-Demo/terraform-aws-webserver/tree/main/canary"
      Workspace = terraform.workspace
    }
  }
  region = "eu-west-2"
}

module "webserver" {
  source = "../"
}


