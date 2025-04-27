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
  default     = "us-east-1"  # Modify as per your region
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

resource "aws_eks_cluster" "main" {
  name     = "healthcare-cluster"
  role_arn = "arn:aws:iam::774305615726:role/eks-service-role"

  vpc_config {
    subnet_ids = ["subnet-12345678", "subnet-87654321"]
  }
}

resource "aws_security_group" "eks" {
  name        = "eks-sg"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-12345678"
}

