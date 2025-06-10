terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = "us-east-1"
}

# Create a new VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "cowrie-vpc" }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = { Name = "public-subnet" }
}

# Create an internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "cowrie-igw" }
}

# Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-route-table" }
}

# Associate route table with subnet
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create key pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-2"
  public_key = file("C:/Users/sumah/.ssh/deployer-key-2.pub")

}

# Create security group
resource "aws_security_group" "cowrie_sg" {
  name        = "cowrie-sg"
  description = "Allow SSH and Cowrie ports"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 23
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch EC2 instances
resource "aws_instance" "cowrie_instance" {
  count                       = 1
  ami                         = "ami-084568db4383264d4" # Ensure this is valid for us-east-1
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  key_name                    = "deployer-key-2" # MAKE KEY in AWS EC2 console in same region (east-1 etc)
  vpc_security_group_ids      = [aws_security_group.cowrie_sg.id]
  associate_public_ip_address = true
  
  # User data to run the script
  user_data = file("user_data.sh")

  tags = {
    Name = "Cowrie-Honeypot-${count.index + 1}"
  }
}

output "instance_public_ips" {
  value = [for instance in aws_instance.cowrie_instance : instance.public_ip]
}
