resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

locals {
  bucket_name = "${var.project_name}-${var.my_name}-${random_string.suffix.result}-tf-states"
  common_tags = {
    Environment = var.my_name
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket" "terraform_states" {
  bucket = local.bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_states.id
  versioning_configuration {
    status = "Enabled"
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "devops1125"
}

variable "my_name" {
  description = "My Name"
  type        = string
}

output "s3_bucket_name" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.terraform_states.bucket
}

terraform {
  backend "local" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "XXXXX"
  secret_key = "XXXXX"
}
