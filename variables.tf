# AWS Region
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# VPC variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.123.0.0/16"
}

variable "access_ip" {
  type = string
  default = "0.0.0.0/0"
  #default = "73.87.146.57/32"

}

# variable "my_ip" {
#   type    = string
#   default = "73.87.146.57/32"
# }

variable "public_cidrs" {
  type    = list(string)
  default = ["10.123.1.0/24", "10.123.3.0/24"]
}

variable "private_cidrs" {
  type    = list(string)
  default = ["10.123.2.0/24", "10.123.4.0/24"]
}

variable "main_instance_type" {
  type    = string
  default = "t2.micro"

}

variable "main_vol_size" {
  type    = number
  default = 8
}

variable "main_instance_count" {
  type    = number
  default = 3

}

# variable "create_ingress_rule" {
#   type    = bool
#   default = yes
# }

variable "key_name" {
  type = string
}

variable "public_key_path" {
  type = string
}
# Already defined in main.tf
# variable "public_subnet_cidr" {
#   description = "CIDR block for the public subnet"
#   type        = list(string)
#   default     = ["10.0.10.0/24", "10.0.20.0/24"]
# }

# variable "private_subnet_cidr" {
#   description = "CIDR block for the private subnet"
#   type        = list(string)
#   default     = ["10.0.40.0/24", "10.0.50.0/24"]
# }

# Basic terraform skills use others
# variable "private_subnet_cidr" {
#   description = "CIDR block for the private subnet"
#   type        = string
#   default     = "10.0.2.0/24"
# }

# variable "availability_zone" {
#   description = "Availability zone for subnets"
#   type        = string
#   default     = "us-east-1a"
# }

# # EC2 instance variables
# variable "jump_box_ami" {
#   description = "AMI ID for the jump box instance"
#   type        = string
#   default     = "ami-0866a3c8686eaeeba"
# }

# variable "cicd_ami" {
#   description = "AMI ID for the CI/CD server"
#   type        = string
#   default     = "ami-0866a3c8686eaeeba"
# }

# variable "web_server_ami" {
#   description = "AMI ID for the web server instance"
#   type        = string
#   default     = "ami-0866a3c8686eaeeba"
# }

# variable "key_name" {
#   description = "Name of the EC2 key pair"
#   type        = string
#   sensitive   = true
# }

# variable "admin_ip" {
#   description = "IP address for SSH access"
#   type        = string
#   sensitive   = true
# }

# variable "instance_type_jump_box" {
#   description = "Instance type for the jump box"
#   type        = string
#   default     = "t2.micro"
# }

# variable "instance_type_cicd" {
#   description = "Instance type for the CI/CD server"
#   type        = string
#   default     = "t2.medium"
# }

# variable "instance_type_web_server" {
#   description = "Instance type for the web server"
#   type        = string
#   default     = "t2.micro"
# }

# Added 
# variable "ports" {
#   type    = list(number)
#   default = [22, 80, 443, 8080, 8081]
# }
