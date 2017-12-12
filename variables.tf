# remote configuration
terraform {
  required_version = ">= 0.11.1"

  backend "s3" {
    encrypt = "true"
  }
}

# aws provider
provider "aws" {
  region = "us-east-2"
}

# fetching coreos AMI
data "aws_ami" "coreos" {
  filter {
    name   = "name"
    values = ["CoreOS-stable-1576.4.0-hvm"] # Fixed value to avoid recreation of instances
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["595879546273"] # CoreOS
}

# path to ssh public key
variable "public_key_path" {
  default = "~/.ssh/3-tier.pub"
}

# name of the key to be used
variable "key_name" {
  default = "guilherme-ssh-key"
}

# EC2 machine instance type 
variable "instance_type" {
  default = "t2.micro"
}
