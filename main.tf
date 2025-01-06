# main.tf

provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.38.0, ~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
  }
}

# Generate a random ID for unique S3 bucket naming
resource "random_id" "randomness" {
  byte_length = 8
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "jenkins-vpc"
  }
}

# Create a Subnet
resource "aws_subnet" "subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "jenkins-Subnet"
    Type = "Public"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "jenkins-igw"
  }
}

# Create a Route Table
resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public"
  }
}

# Associate the Subnet with the Route Table
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt1.id
}

# Create Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH, HTTP, and HTTPS Traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
  }

  ingress {
    description = "Jenkins HTTP"
    from_port   = var.jenkins_port
    to_port     = var.jenkins_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# Fetch the latest Ubuntu 22.04 LTS AMI in eu-west-1
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Create EC2 Instance
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true

  key_name = var.key_name

  tags = {
    Name = "Jenkins"
  }

  # User Data to install Jenkins
  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    jenkins_port = var.jenkins_port
  })
}

# Create S3 Bucket with a unique name and enforce bucket ownership
resource "aws_s3_bucket" "jenkinsbucket" {
  bucket = "jenkinsbucket-${random_id.randomness.hex}"


  tags = {
    Name = "jenkins-bucket"
  }
}

# Removed aws_s3_bucket_acl to fix ACL error
