variable "AWS_ACCESS_KEY_ID" {
  description = "The AWS access key"
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "The AWS secret access key"
  type        = string
  sensitive   = true
}

variable "AWS_REGION" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

# ✅ Fetch subnets from your VPC in supported availability zones
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = ["vpc-07b4ac398e1b4c4d5"]
  }

  # Ensure subnets are in supported availability zones for EKS
  filter {
    name   = "availabilityZone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

# ✅ Create a security group (Updated to avoid duplicate)
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

  tags = {
    Name = "eks-sg"
  }
}

# ✅ Create EKS cluster using the fetched subnets
resource "aws_eks_cluster" "main" {
  name     = "healthcare-cluster"
  role_arn = "arn:aws:iam::774305615726:role/eks-service-role"

  vpc_config {
    subnet_ids         = data.aws_subnets.selected.ids
    security_group_ids = [aws_security_group.eks.id]  # Ensure correct referencing
  }
}
