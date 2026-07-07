################################################
################# providers.tf #################
################################################

terraform {
  required_version = ">= 1.10.0"

  backend "local" {}

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



################################################
#################### data.tf ###################
################################################

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



################################################
################ test-server.tf ################
################################################

# 1. COUNT: Used here as a condition (Only create if 'create_test_instance' is true)
resource "aws_instance" "test_server" {
  count         = var.create_test_instance ? 1 : 0
  ami           = "ami-06067086cf86c58e6"
  instance_type = "t3.micro"

  subnet_id                   = data.aws_subnet.primary.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ping.id]

  tags = {
    Name = "Conditional-Instance"
  }
}

resource "aws_security_group" "allow_ping" {
  name        = "my-instance-sg"
  description = "Allow ICMP ping from anywhere"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 8 # ICMP type 8 (Echo Request)
    to_port     = 0 # ICMP code
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
    always_run  = timestamp()
    instance_ip = aws_instance.test_server[0].public_ip
  }

  provisioner "local-exec" {
    # -c 4 sends 4 packets (Linux/Mac). Use -n 4 if you are on Windows.
    command = "ping -c 4 ${self.triggers.instance_ip}"
  }

  depends_on = [aws_instance.test_server, aws_security_group.allow_ping]
}



################################################
############### count-server.tf ################
################################################

# 2. FOR_EACH: Create multiple instances based on a Map
resource "aws_instance" "web_servers" {
  for_each      = var.server_config

  ami           = "ami-06067086cf86c58e6"
  instance_type = each.value
  subnet_id     = data.aws_subnet.primary.id

  tags = {
    Name = "Web-Server-${each.key}"
  }
}

# 3. NULL RESOURCE: Runs a local script or command
# This doesn't create AWS infra, it just executes a task on your computer
resource "null_resource" "post_deploy_msg" {
  for_each = var.server_config
  triggers = {
    # This ensures the script runs every time the VPC ID / instance name changes, even if the instance itself doesn't change.
    # To always run, you can also add a timestamp to the triggers map (always_run = timestamp())
    instance_name = each.key
    vpc_id        = data.aws_vpc.default.id
  }

  provisioner "local-exec" {
    command = "echo \"Deployment to ${self.triggers.instance_name} completed in VPC ${self.triggers.vpc_id}!\" >> /tmp/deployment.log"
  }

  depends_on = [aws_instance.web_servers]
}



################################################
################### locals.tf ##################
################################################

locals {
  # [for k, v in map : expr] -> produces a LIST
  server_summary = [for name, type in var.server_config : "${name}: ${type}"]

  # { for k, v in map : k => v } -> produces a MAP (note the curly braces
  # and the "=>" instead of a plain expression)
  server_config_upper = { for name, type in var.server_config : upper(name) => type }
}



################################################
################### outputs.tf ##################
################################################

output "server_summary" {
  description = "Human-readable list built with a for expression over server_config"
  value       = local.server_summary
}

output "server_config_upper" {
  description = "Map of server names to instance types in uppercase"
  value       = local.server_config_upper
}

output "web_server_private_ips" {
  description = "Private IPs of every web server, collected with a for expression over a for_each-created resource"
  value       = [for name, instance in aws_instance.web_servers : instance.private_ip]
}



################################################
################# variables.tf #################
################################################

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
