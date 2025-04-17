provider "aws" {
  region = "us-east-1"
}

variable "ami" {
    description = "This is AMI instance"
  
}

variable "instance_type" {
  description = "Type of instance for the enivrionment"
}
resource "aws_instance" "main_ec2_instance" {
  ami = var.ami
  instance_type = var.instance_type
}