# main.tf  file for full cicd

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}

locals {
  azs = data.aws_availability_zones.available.names
}
# Add data source
data "aws_availability_zones" "available" {}

# Random ID
resource "random_id" "random" {
  byte_length = 2

}

# Define VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    # Name = "dev_vpc"
    Name = "dev_vpc-${random_id.random.dec}"
    #Name = "dev_vpc-${random_integer.random.id}"
  }
  # Lifecycle allows New vpc to connect to IGW before deleting old vpc to avoid conflicts. Help in the Future
  lifecycle {
    create_before_destroy = true

  }
}

# Define public subnet
resource "aws_subnet" "public_subnet" {
  # count                   = length(var.public_subnet_cidr)
  count  = length(local.azs)
  vpc_id = aws_vpc.dev_vpc.id
  # cidr_block              = var.public_subnet_cidr[count.index] # using cidrsubnet instead
  # cidr_block = cidrsubnet("10.0.10.0/16", 8, length(local.azs) + 1)
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  #availability_zone       = var.availability_zone
  #availability_zone = data.aws_availability_zones.available.names[count.index]
  availability_zone = local.azs[count.index]
  tags = {
    Name = "dev-public-subnet-${count.index + 1}"
  }
}

# Define private subnet
resource "aws_subnet" "private_subnet" {
  #count                   = length(var.private_subnet_cidr)
  count  = length(local.azs)
  vpc_id = aws_vpc.dev_vpc.id
  # cidr_block              = var.private_subnet_cidr[count.index]
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, length(local.azs) + count.index)
  map_public_ip_on_launch = false
  #availability_zone       = var.availability_zone
  # availability_zone = data.aws_availability_zones.available.names[count.index]
  availability_zone = local.azs[count.index]
  tags = {
    Name = "dev-public-subnet-${count.index + 1}"
  }
}

# Add Route Table Association

resource "aws_route_table_association" "dev_public_assoc" {
  count = length(local.azs)
  #subnet_id      = aws_subnet.public_subnet[count.index].id # Newly commented out 11/15/24
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_route_table.id
}


# Create Security Group 
resource "aws_security_group" "dev_sg" {
  name        = "dev_sg"
  description = "Security Group for Public Instance"
  vpc_id      = aws_vpc.dev_vpc.id
}

resource "aws_security_group_rule" "ingress_all" {
  # count     = var.create_ingress_rule ? 1 : 0 # gpt yeye
  type      = "ingress"
  from_port = 0
  to_port   = 65535
  protocol  = "-1"
  #cidr_blocks       = [var.access_ip, var.my_ip, var.cloud9_ip]
  cidr_blocks       = [var.access_ip]
  security_group_id = aws_security_group.dev_sg.id

  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.dev_sg.id
}


# # Define private subnet - Old basic config
# resource "aws_subnet" "private_subnet" {
#   vpc_id            = aws_vpc.dev_vpc.id
#   cidr_block        = var.private_subnet_cidr
#   availability_zone = var.availability_zone
#   tags = {
#     Name = "dev-private-subnet"
#   }
# }

# Define internet gateway for public access
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    # Name = "dev_igw"
    Name = "dev_igw-${random_id.random.dec}"
  }
}

# Define route table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "dev-public-route-table"
  }
}

# Default Route Table. Must be explicitly Called
resource "aws_route_table" "default_route_table" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "default-public-route-table"
  }
}
# Create route table newly added
resource "aws_default_route_table" "dev_private_rt" {
  default_route_table_id = aws_vpc.dev_vpc.default_route_table_id
  tags = {
    Name = "dev_private"
  }
}


# # Associate route table with public subnet
# resource "aws_route_table_association" "public_subnet_assoc" {
#   # subnet_id      = aws_subnet.public_subnet.id
#   subnet_id      = var.public_subnet_cidr[count.index]
#   route_table_id = aws_route_table.public_route_table.id
# }

