terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.27"
    }
  }

}

provider "aws" {
  region = "us-east-1"
}

locals {
  app_port = 22
}

#variable "name" {
#  type = string
#}
# ------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------
# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 3.0"

#   name = "HelloWorldVPC"

#   cidr = "10.0.0.0/16"

#   azs             = ["us-east-1a"]
#   public_subnets  = ["10.0.1.0/24"]
#   private_subnets = ["10.0.21.0/24"]

#   enable_nat_gateway = true
# }

resource "aws_vpc" "HelloWorld_vpc_1" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
 

}
resource "aws_security_group" "hello_world-22-sg" {
  name = "hello_world-ec2-sg"

  ingress {
    description = "Allow Inbound to 22"
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    cidr_blocks = ["156.249.11.137/32"]
  }

  #Outgoing traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "HelloWorldKey" # Create "myKey" to AWS
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "HelloWorldKey.pem" to your computer
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./HelloWorldKey.pem"
  }
}
resource "aws_key_pair" "ssh-key" {
  key_name   = "ssh-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7MWvd+EGmqASrpQGI+Wl7/JYntkYJ91c/7SkQ0rHyUt84NTR8VX/lKHm5yjvJ+JdfIlou0GSz+zv9cRZn+wi83zjah6tB+vLg5WSoYpkhs/CNixsmkvxgt55XajFa+R4rKS7lAChM5teTKM83u9ccQxQYKcOZCx6B2urZ/IuvIYWoY/zrY21itCPk28KQ2Lx9wtEGTh2GJBda1YCjpOl7zN2Ds/XYFKGfcL20B2y2fBoVpoNtMQJhN0NrKTV0iAEivATvUod/Q66n91FDSB+EVg0ECU6+yZ/GPwEY/1obVD+SFqYKuGjwF7GIec+8T1tWSjQS6wda+DmJf10r1VNjacfxCCXXsvqVPIC4glq3a3OjmWIjGoQ1FwNr+t9Uv7davV/0eUEAWUmunG813PwLSvNEkp6+EJGAUu1f3z8qKPuT7/3gKuGg88ny/YY2Gu2MQhVOEgpOtzhm/ctRtLXxPYoHJ5PfnN+C0VfnfO9j0Y6DE2fwlWoG9gKdPkvMiMc= chorboon@fedora"
}

resource "aws_instance" "hello_world-1" {
  ami             = "ami-02f3f602d23f1659d"
  instance_type   = "t2.micro"
  key_name        = "ssh-key"
  security_groups = ["hello_world-22-sg"]

  provisioner "remote-exec" {

    connection {
      type = "ssh"
      user = "ec2-user"
      #      certificate = file("HelloWorldKey.pem")
      private_key = file("~/.ssh/id_rsa2")
      host        = self.public_ip
    }
    inline = [
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
    ]


  }
}