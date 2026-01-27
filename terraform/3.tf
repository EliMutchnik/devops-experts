###### ec2_with_ping module ######

# 1. The Security Group
resource "aws_security_group" "this" {
  name        = "${var.instance_name}-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Conditional SG Rule (Only created if enable_ping is true)
resource "aws_security_group_rule" "allow_icmp" {
  count             = var.enable_ping ? 1 : 0
  type              = "ingress"
  from_port         = 8
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
}

# 3. The EC2 Instance
resource "aws_instance" "this" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  
  vpc_security_group_ids      = [aws_security_group.this.id]
  associate_public_ip_address = true

  tags = { Name = var.instance_name }
}

# 4. The Null Resource (Conditional and "Run Always")
resource "null_resource" "ping_test" {
  count = var.enable_ping ? 1 : 0

  triggers = {
    # Using a timestamp makes this resource "change" on every apply
    always_run = timestamp()
    ip_address = aws_instance.this.public_ip
  }

  provisioner "local-exec" {
    command = "ping -c 3 ${aws_instance.this.public_ip}"
  }

  depends_on = [aws_instance.this, aws_security_group_rule.allow_icmp]
}

###### Variables ######

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the Security Group will be created"
  type        = string
}

variable "enable_ping" {
  description = "Enable ICMP ping rule and ping test"
  type        = bool
  default     = false
}

###### Outputs ######

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.this.public_ip
}


############# Usage Example #############


terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "" # <--- YOUR BUCKET NAME HERE
    key            = "state/3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "XXXXX"
  secret_key = "XXXXX"
}

# Data sources to get network info (same as previous steps)
data "aws_vpc" "default" { 
  default = true 
}

data "aws_subnets" "all" {
  filter { 
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Instance 1: Development (Ping Enabled)
module "dev_server" {
  source        = "./modules/ec2_with_ping"
  instance_name = "Dev-Server"
  instance_type = "t3.micro"
  ami_id        = "ami-07ff62358b87c7116"
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.all.ids[0]
  enable_ping   = true
}

# Instance 2: Production (Ping Disabled)
module "prod_server" {
  source        = "./modules/ec2_with_ping"
  instance_name = "Prod-Server"
  instance_type = "t3.small"
  ami_id        = "ami-07ff62358b87c7116"
  vpc_id        = data.aws_vpc.default.id
  subnet_id     = data.aws_subnets.all.ids[1]
  enable_ping   = false
}
