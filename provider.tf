#Provider block
provider "aws" {
  region                  = var.aws_region
  #shared_credentials_file = "/mnt/c/Users/victo/.aws/credentials"
  shared_credentials_file = "/home/ubuntu/.aws/credentials"
  #profile = default
}
