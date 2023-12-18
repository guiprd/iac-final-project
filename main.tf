terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "region" {
  default = "us-east-1"
}

provider "aws" {
  region = "${var.region}"
  access_key = file("./keys/access.txt")
  secret_key = file("./keys/secret.txt")
}

resource "aws_key_pair" "ssh-key" {
    key_name = "ssh-key"
    public_key = file("./keys/id_rsa.pub")
}

resource "aws_security_group" "access" {
  name = "access"
  description = "all"
  ingress{
      cidr_blocks = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
      from_port = 0
      to_port = 0
      protocol = "-1"
  }
  egress{
      cidr_blocks = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
      from_port = 0
      to_port = 0
      protocol = "-1"
  }
  tags = {
    Name = "access"
  }
}


resource "aws_instance" "application_server" {
    ami           = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    key_name      = "ssh-key"

    vpc_security_group_ids = [
        "access"
    ] 
}

output "IP_Publico" {
  value = aws_instance.application_server.public_ip
}