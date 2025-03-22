terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "ap-south-1"
  profile    = "tf-user"
  access_key = var.access_key
  secret_key = var.secret_key
}

module "ecr" {
  source = "./ecr"
}


module "ecs" {
  source = "./ecs"
  flask_repo_url = module.ecr.flask_repo_url
  express_repo_url = module.ecr.express_repo_url
}