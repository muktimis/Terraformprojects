provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "main_instance" {
  instance_type = "t2.micro"
  ami = "ami-0100e595e1cc1ff7f"
  
}

resource "aws_s3_bucket" "bucket_name" {
    bucket = "mukti-bucket-aws-demo-xop"
  
}

resource "aws_dynamodb_table" "Lock-table" {
  name           = "terraform lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  range_key      = "GameTitle"

  attribute {
    name = "LockID"
    type = "S"
  }
}