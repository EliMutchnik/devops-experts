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

# Installing K3S
https://k3s.io/
curl -sfL https://get.k3s.io | sh - 

# Check for Ready node, takes ~30 seconds 
sudo k3s kubectl get node 
k3s kubectl get pods -A
alias kubectl='k3s kubectl'

# Running NGINX (via docker)
# -------------------
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:stable-alpine
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: LoadBalancer
# -------------------
kubectl apply -f nginx.yaml
kubectl get pods


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
  ami           = "ami-07ff62358b87c7116" # Amazon Linux 2 AMI
  instance_type = "t3.micro"

  tags = {
    Name = local.instance_name
  }
}

output "ip" {
  value = aws_instance.my_first_instance.public_ip
}
