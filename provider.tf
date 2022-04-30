################################
########### PROVIDERS ##########
################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.9.0"
    }

    github = {
      source  = "integrations/github"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

provider "github" {
  token = var.github_token
}
