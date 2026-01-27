terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "" # <--- YOUR BUCKET NAME HERE
    key            = "state/4/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "XXXXX"
  secret_key = "XXXXX"
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "free-tier-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a"]
  public_subnets = ["10.0.1.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


### Class Ex
# Create 2 S3 buckets in a loop that contains your name and a random suffix
# Create an EC2 instance and a null resource that writes the public IP of the instance to a file
