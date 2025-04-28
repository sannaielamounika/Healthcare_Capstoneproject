provider "aws" {
  region = "us-east-1"
}

data "aws_subnets" "selected" {
  vpc_id = "vpc-07b4ac398e1b4c4d5"
}

data "aws_security_group" "eks" {
  id = "sg-0ff4d28e49c926716"  # Updated with the actual Security Group ID
}

resource "aws_eks_cluster" "main" {
  name     = "healthcare-cluster"
  role_arn = "arn:aws:iam::774305615726:role/eks-service-role"

  vpc_config {
    subnet_ids         = data.aws_subnets.selected.ids
    security_group_ids = [data.aws_security_group.eks.id]  # Reference the existing security group
  }

  # Cluster settings
  kubernetes_network_config {
    service_ipv4_cidr = "172.20.0.0/16"
  }

  # Specify the EKS version you want to use
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
