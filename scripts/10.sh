# Creating EC2 instance - https://us-east-1.console.aws.amazon.com/ec2/
https://instances.vantage.sh

# Installing Docker
sudo -i
yum install docker -y
systemctl enable docker
systemctl start docker

# Running NGINX (via docker)
docker run -d -p 80:80 --name nginx nginx:alpine
# Getting to the NGINX + edit Security groups with my IP
docker rm -f nginx

# Calculator and billing
http://calculator.aws/

# Creating IAM user
AmazonEC2FullAccess
https://aws.permissions.cloud


# Terraform
https://developer.hashicorp.com/terraform/install
https://registry.terraform.io/browse/providers

https://registry.terraform.io/providers/hashicorp/aws/latest/docs
----------------
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

locals {
  instance_name = "ExampleInstance"
}

resource "aws_instance" "my_first_instance" {
  ami           = "ami-06067086cf86c58e6" # Amazon Linux 2 AMI
  instance_type = "t3.micro"

  tags = {
    Name = local.instance_name
  }
}

output "ip" {
  value = aws_instance.my_first_instance.public_ip
}

# Add security group with your current ip with port 80
# Add outputs: instance id, instance state and security group id
