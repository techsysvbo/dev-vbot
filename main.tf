# Tf file for full cicd
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}
# Define VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block       = var.vpc_cidr

  tags = {
    Name = "dev-vpc"
  }
}

# Define public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags = {
    Name = "dev-public-subnet"
  }
}

# Define private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone
  tags = {
    Name = "dev-private-subnet"
  }
}

# Define internet gateway for public access
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "dev-igw"
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

# Associate route table with public subnet
resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Define security group for jump box
resource "aws_security_group" "jump_box_sg" {
  name = "jump_box_sg Security Group"
  description = "To Allow Port"
  vpc_id = aws_vpc.dev_vpc.id

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [var.admin_ip]
#   }

  dynamic "ingress" {
     iterator = port
     for_each = var.ports
     content {
       from_port = port.value
       to_port   = port.value
       protocol  = "tcp"
      #cidr_blocks = ["44.214.100.9/32"]
       cidr_blocks = var.vpc_cidr.id 
     }
 
   }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-jump-box-sg"
  }
}

# Define EC2 jump box instance
resource "aws_instance" "jump_box" {
  ami                    = var.jump_box_ami
  instance_type          = var.instance_type_jump_box
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jump_box_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "dev-jump-box"
  }
}

# Define CI/CD instance
resource "aws_instance" "cicd_server" {
  ami                    = var.cicd_ami
  instance_type          = var.instance_type_cicd
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jump_box_sg.id]

  tags = {
    Name = "dev-cicd-server"
  }
}

# Define private EC2 instance (Web Server)
resource "aws_instance" "web_server" {
  ami                    = var.web_server_ami
  instance_type          = var.instance_type_web_server
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.jump_box_sg.id]
  key_name               = var.key_name
  #user_data = file("${path.module}/InstallDocker.sh")

  tags = {
    Name = "dev-web-server"
  }
}
