provider "aws" {
 region = "ap-northeast-1"
}

resource "aws_key_pair" "key-pair" {
 key_name = "akshay"
 public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICW83+m1x5+OYLne5EzKqAeTwUTja7/yXH99L+vcprOJ root@ip-172-31-38-132"
}

variable "cidr" {
default = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "mysub" {
 vpc_id = aws_vpc.main.id
 cidr_block = "10.0.1.0/24"
}

resource "aws_internet_gateway" "ig" {
 vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
 vpc_id = aws_vpc.main.id
 route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
 }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysub.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_instance" "myec2" {
 instance_type = "t2.micro"
 subnet_id = aws_subnet.mysub.id
 ami = "ami-0a290015b99140cd1"
 tags = {
  Name = "Akshay"
 }
}

output "vpc" {
 value = aws_vpc.main.id
}
