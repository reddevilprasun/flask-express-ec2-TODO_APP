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

resource "aws_security_group" "frontend-todo" {
  name        = "frontend-todo"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "vpc-0220fc988284813ae"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "backend-todo" {
  name        = "backend-todo"
  description = "Allow HTTP inbound traffic"
  vpc_id      = "vpc-0220fc988284813ae"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_frontend_anywhere" {
  security_group_id = aws_security_group.frontend-todo.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  to_port           = 3000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_backend_anywhere" {
  security_group_id = aws_security_group.backend-todo.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  to_port           = 5000
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ivp4_frontend" {
  security_group_id = aws_security_group.frontend-todo.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ivp4_backend" {
  security_group_id = aws_security_group.backend-todo.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 0
  ip_protocol       = "-1"
}

resource "aws_instance" "frontend-todo" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  user_data = file("frontend-user.sh")
  key_name      = "web-todo-key"
  security_groups = [aws_security_group.frontend-todo.name]

  tags = {
    Name = "Flask-Todo"
  }
}

resource "aws_instance" "backend-todo" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  user_data = file("backend-user.sh")
  key_name      = "web-todo-key"
  security_groups = [aws_security_group.backend-todo.name]

  tags = {
    Name = "Express-Todo"
  }
}

output "frontend_public_ip" {
  value = aws_instance.frontend-todo.public_ip
}

output "backend_public_ip" {
  value = aws_instance.backend-todo.public_ip
}