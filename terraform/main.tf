# Declare AWS credentials and region as variables
variable "AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "AWS_REGION" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"  # Default region if not provided
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

data "aws_subnets" "selected" {
  vpc_id = "vpc-07b4ac398e1b4c4d5"
}

data "aws_security_group" "eks" {
  id = "sg-0ff4d28e49c926716"  # Existing security group ID for EKS
}

resource "aws_eks_cluster" "main" {
  name     = "healthcare-cluster"
  role_arn = "arn:aws:iam::774305615726:role/eks-service-role"

  vpc_config {
    subnet_ids         = data.aws_subnets.selected.ids
    security_group_ids = [data.aws_security_group.eks.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }

  version = "1.21"
}

resource "aws_security_group" "eks" {
  name        = "eks-sg"
  description = "Allow all inbound traffic for EKS"
  vpc_id      = "vpc-07b4ac398e1b4c4d5"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
