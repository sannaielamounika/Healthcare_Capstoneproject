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

# Corrected data source for fetching subnets
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = ["vpc-07b4ac398e1b4c4d5"]  # Your VPC ID
  }
}

# Check for the existing security group
data "aws_security_group" "eks" {
  id = "sg-0ff4d28e49c926716"  # Existing security group ID for EKS
}

# Use existing EKS cluster if it already exists
data "aws_eks_cluster" "existing" {
  name = "healthcare-cluster"
}

# Use existing EKS cluster if it exists, else create a new one
resource "aws_eks_cluster" "main" {
  count    = length(data.aws_eks_cluster.existing) == 0 ? 1 : 0  # Only create if not existing
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

# Use existing security group, or skip creation if it exists
resource "aws_security_group" "eks" {
  count       = length(data.aws_security_group.eks) == 0 ? 1 : 0  # Only create if not existing
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
