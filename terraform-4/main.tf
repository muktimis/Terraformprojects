provider "aws" {
  region = "us-east-1"
}

variable "cidr" {
  default = "10.0.0.0/16"

}

resource "aws_key_pair" "keys" {
    key_name = "id_rsa"
    public_key = file("~/.ssh/id_rsa.pub")  
  
}
resource "aws_vpc" "mainvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  cidr_block = "10.0.0.0/24"
  vpc_id = aws_vpc.mainvpc.id
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.mainvpc.id
  
}

resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.mainvpc.id

    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
  
}

resource "aws_route_table_association" "igw_t" {
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_internet_gateway.igw.id
}

resource "aws_security_group" "msg" {
  name = "web"
  vpc_id = aws_vpc.mainvpc.id

    ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["209.227.141.16/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }

}

resource "aws_instance" "server" {
  ami                    = "ami-0261755bbcb8c4a84"
  instance_type          = "t2.micro"
  key_name = aws_key_pair.keys.key_name
  vpc_security_group_ids = [aws_security_group.msg.id]
  subnet_id = aws_subnet.sub1.id

  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "file" {
    source = "app.py"
    destination = "/home/ubuntu/app.py" 
    
  }

    provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu)
      "sudo apt-get install -y python3-pip",  # Example package installation
      "cd /home/ubuntu",
      "sudo pip3 install flask",
      "sudo python3 app.py &",
    ]
  }
  
}