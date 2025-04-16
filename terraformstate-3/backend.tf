terraform {
 backend "s3" {
    bucket = "mukti-bucket-aws-demo-xop"
    key    = "mukti/terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "Lock-table"
  }
}
