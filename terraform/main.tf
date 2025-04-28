provider "aws" {
  region = "us-east-1" # Replace with your AWS region
}

# Ensure the VPC exists
data "aws_vpc" "selected" {
  id = "vpc-07b4ac398e1b4c4d5" # Replace with your VPC ID
}

# Check if the security group exists or create it
resource "aws_security_group" "eks" {
  name        = "eks-sg"
  description = "Security Group for EKS"
  vpc_id      = data.aws_vpc.selected.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-sg"
  }
}

# Optional: Adding an output for debugging
output "security_group_id" {
  value = aws_security_group.eks.id
}
