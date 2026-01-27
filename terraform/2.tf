terraform {
  required_version = ">= 1.10.0"

  backend "s3" {
    bucket         = "" # <--- YOUR BUCKET NAME HERE
    key            = "state/2/terraform.tfstate"
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



data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "primary" {
  id = data.aws_subnets.all.ids[0]
}




# 1. COUNT: Used here as a condition (Only create if 'create_test_instance' is true)
resource "aws_instance" "test_server" {
  count         = var.create_test_instance ? 1 : 0
  ami           = "ami-07ff62358b87c7116"
  instance_type = "t3.micro"

  subnet_id     = data.aws_subnet.primary.id
  associate_public_ip_address = true

  tags = {
    Name = "Conditional-Instance"
  }
}

resource "aws_security_group" "allow_ping" {
  name        = "${var.project_name}-sg"
  description = "Allow ICMP ping from anywhere"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 8  # ICMP type 8 (Echo Request)
    to_port     = 0  # ICMP code
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "ping_test" {
  triggers = {
    instance_ip = aws_instance.test_server[0].public_ip
  }

  provisioner "local-exec" {
    # -c 4 sends 4 packets (Linux/Mac). Use -n 4 if you are on Windows.
    command = "ping -c 4 ${self.triggers.instance_ip}"
  }

  depends_on = [aws_instance.test_server]
}



# 2. FOR_EACH: Create multiple instances based on a Map
resource "aws_instance" "web_servers" {
  for_each      = var.server_config

  ami           = "ami-07ff62358b87c7116"
  instance_type = each.value
  subnet_id     = data.aws_subnet.primary.id

  tags = {
    Name = "Web-Server-${each.key}"
  }
}

# 3. NULL RESOURCE: Runs a local script or command
# This doesn't create AWS infra, it just executes a task on your computer
resource "null_resource" "post_deploy_msg" {
  triggers = {
    # This ensures the script runs every time the VPC ID changes
    vpc_id = data.aws_vpc.default.id
  }

  provisioner "local-exec" {
    command = "echo Deployment complete in VPC ${data.aws_vpc.default.id}!"
  }
}





variable "create_test_instance" {
  description = "Set to true to create the test EC2"
  type        = bool
  default     = true
}

variable "server_config" {
  description = "A map of server names to instance types"
  type        = map(string)
  default     = {
    "nginx"  = "t3.micro",
    "apache" = "t3.small"
  }
}
