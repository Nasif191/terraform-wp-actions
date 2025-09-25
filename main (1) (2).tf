# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"  # Set AWS region to US East 1 (N. Virginia)
}

# Local variables block for configuration values
locals {
    aws_key = "Nasif_swen-514"   # SSH key pair name for EC2 instance access
}

data "aws_vpc" "default" {
    default = true
  }

# EC2 instance resource definition
resource "aws_instance" "my_server" {
   ami           = data.aws_ami.amazonlinux.id  # Use the AMI ID from the data source
   instance_type = var.instance_type            # Use the instance type from variables
   key_name      = "Nasif_swen-514"          # Specify the SSH key pair name


   vpc_security_group_ids      = [aws_security_group.wp_sg.id]
   associate_public_ip_address = true
   user_data                   = file("${path.module}/wp_install.sh")


   # Add tags to the EC2 instance for identification
   tags = {
     Name = "my ec2"
   }
}
# Security Group that allows SSH and HTTP from anywhere
resource "aws_security_group" "wp_sg" {
    name_prefix = "wp-sg-"          # ← replaces name = "wp-sg"
    description = "Allow SSH (22) and HTTP (80)"
    vpc_id      = data.aws_vpc.default.id


ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
ipv6_cidr_blocks = ["::/0"]
}
 ingress {
   description      = "HTTP"
   from_port        = 80
   to_port          = 80
   protocol         = "tcp"
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
 }

    tags = { Name = "wp-sg" }
 }

 terraform {
  backend "s3" {
    bucket         = "terraform-wordpress-activity-bucket"          # Replace with your S3 bucket name
    key            = "terraform/wp/terraform.tfstate"  # Path to the state file in the bucket
    region         = "us-east-2"                    # Must match the region of your S3 bucket
  }
}