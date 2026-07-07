################################################
################# providers.tf #################
################################################

terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "" # <--- YOUR BUCKET NAME FROM EX1 HERE
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


################################################
#################### vpc.tf ####################
################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "free-tier-vpc-${var.environment}"
  cidr = var.network_config.cidr_block

  azs            = slice(data.aws_availability_zones.available.names, 0, var.network_config.az_count)
  public_subnets = ["10.0.1.0/24"]

  enable_nat_gateway = var.network_config.enable_nat_gateway

  tags = {
    Terraform   = "true"
    Environment = var.environment
}


################################################
#################### data.tf ###################
################################################

data "aws_availability_zones" "available" {
  state = "available"
}


################################################
################# variables.tf #################
################################################

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "network_config" {
  description = "Grouped network settings for this environment"
  type = object({
    cidr_block         = string
    enable_nat_gateway = bool
    az_count           = number
  })
  default = {
    cidr_block         = "10.0.0.0/16"
    enable_nat_gateway = false
    az_count           = 1
  }

  validation {
    # A prod network without a NAT gateway is almost always a mistake.
    condition     = var.environment != "prod" || var.network_config.enable_nat_gateway
    error_message = "prod environments must set network_config.enable_nat_gateway = true."
  }
}

### Terraform commands to run:
# terraform init
# terraform plan -var 'environment=dev' -out /tmp/dev.plan
#  terraform apply /tmp/dev.plan

### To fmt and validate the code:
# terraform fmt -recursive
# terraform validate


######### Class Ex #########
# Create 2 S3 buckets in a loop that contains your name and a random suffix
# Create an EC2 instance and a null resource that writes the public IP of the instance to a file
# Upload this file to both buckets
