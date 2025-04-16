
provider "aws" {
  alias  = "ap-south-1"
  region = "ap-south-1"
}


provider "aws" {
  alias  = "eu-central-1"
  region = "eu-central-1"
}

module "ec2_us_east_1" {
  source        = "./modules/ec2"
  ami_id        = "ami-03f4878755434977f"
  instance_type = "t2.micro"
  region        = "ap-south-1"
  name          = "mukti-ec2-us-east-1"

  providers = {
    aws = aws.ap-south-1
  }
}

module "ec2_eu_central_1" {
  source        = "./modules/ec2"
  ami_id        = "ami-0767046d1677be5a0"
  instance_type = "t2.micro"
  region        = "eu-central-1"
  name          = "mukti-ec2-eu-central-1"

  providers = {
    aws = aws.eu-central-1
  }
}




module "s3_us_east_1" {
  source = "./modules/s3"
  region = "ap-south-1"
  bucket_name = "testbucket2"
  

  providers = {
    aws = aws.ap-south-1
  }
}

module "s3_eu_central_1" {
  source = "./modules/s3"
  region = "eu-central-1"
  bucket_name = "testbucket"

  providers = {
    aws = aws.eu-central-1
  }
}

