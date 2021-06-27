terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

# creating vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
	enable_dns_hostnames = true
  tags = {
    Name = "tf-example"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}
#creating subnet1
resource "aws_subnet" "my_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/17"
  availability_zone = "us-east-2a"
  tags = {
    Name = "tf-example"
  }
}
#creating subnet2
resource "aws_subnet" "my_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.128.0/17"
  availability_zone = "us-east-2b"

  tags = {
    Name = "tf-example"
  }
}
#creating instance
resource "aws_instance" "example" {
  ami           = "ami-0d8d212151031f51c" # us-east-2
  instance_type = "t2.micro"
  key_name         = "terraform"
	associate_public_ip_address = true
subnet_id  = aws_subnet.my_subnet2.id
vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  credit_specification {
    cpu_credits = "unlimited"
  }
  
}


#NSG groups
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
 
  }
  ingress {
    description      = "http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
 
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }

}

resource "aws_route_table" "example" {
 vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route1"
  }
}