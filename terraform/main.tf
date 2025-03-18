terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region     = "ap-south-1"
  profile    = "tf-user"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_security_group" "web-todo" {
  name        = "web-todo"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = "vpc-0220fc988284813ae"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_frontend_anywhere" {
  security_group_id = aws_security_group.web-todo.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_anywhere" {
  security_group_id = aws_security_group.web-todo.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_backend_anywhere" {
  security_group_id = aws_security_group.web-todo.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  to_port           = 5000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ivp4" {
  security_group_id = aws_security_group.web-todo.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
}

resource "aws_instance" "web-todo" {
  ami             = "ami-00bb6a80f01f03502"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web-todo.name]
  user_data = file("user_data.sh")
  key_name = "todo-key"

  tags = {
    Name = "Flask-Express-Todo"
  }
}


output "public_ip" {
  value = aws_instance.web-todo.public_ip
}

