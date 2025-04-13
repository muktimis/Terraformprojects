provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "main_vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "free-tier-vpc"
    }
  
}

resource "aws_subnet" "main_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "free-tier-igw"
  }
}
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_eip" "main_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main_gateway" {
    allocation_id = aws_eip.main_eip.id
    subnet_id = aws_subnet.main_subnet.id

  tags = {
    Name = "free_tier_igw"
  }
}

resource "aws_route_table" "main_route" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main_gateway.id
  }
  tags = {
    Name = "free_tier_routetable"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route.id
}

resource "aws_security_group" "main_security" {
  name = "web_sg"
  description = "Allow SSH AND TH"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }

}

resource "aws_instance" "web_server" {
  ami                    = "ami-0c2b8ca1dad447f8a" # Amazon Linux 2 AMI (Free Tier eligible in us-east-1)
  instance_type          = "t2.micro"             # Free Tier eligible
  subnet_id              = aws_subnet.main_subnet.id
  vpc_security_group_ids = [aws_security_group.main_security.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to Terraform Web Server!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "terraform-web-server"
  }
}
