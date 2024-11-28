provider "aws" {
  region = "us-west-2"  # Adjust the region to your needs
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
}

resource "aws_security_group" "eks_security_group" {
  vpc_id = aws_vpc.main.id
}

# Reference the existing IAM role bharat-eks-cluster-role
data "aws_iam_role" "bharat_eks_cluster_role" {
  name = "bharat-eks-cluster-role"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "blue-green-cluster"
  role_arn = data.aws_iam_role.bharat_eks_cluster_role.arn  # Use the existing role

  vpc_config {
    subnet_ids = aws_subnet.subnet.*.id
  }
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}



#Note: you have role name 'bharat-eks-cluster-role' created on IAM
