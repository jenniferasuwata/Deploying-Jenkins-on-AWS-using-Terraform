# variables.tf

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "eu-west-1a"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0e9085e60087ce171" # Ubuntu 22.04 in eu-west-1
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "ansible"
}

variable "private_key_path" {
  description = "Path to the SSH private key"
  type        = string
  default     = "/Users/jenniferasuwata/Desktop/Key Pairs/ansible.pem" # Update this path as needed
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed to SSH into the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # For better security, restrict this to your IP
}

variable "jenkins_port" {
  description = "Port Jenkins will run on"
  type        = number
  default     = 8080
}
