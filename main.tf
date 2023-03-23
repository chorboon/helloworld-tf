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
  app_port = 80
}
resource "aws_vpc" "HelloWorld_vpc_1" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"


}

resource "aws_eip" "frontend-lb-1" {
  vpc = true
}
resource "aws_eip" "frontend-lb-2" {
  vpc = true
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}


resource "aws_nat_gateway" "nat_gateway" {
  subnet_id   = aws_subnet.public_subnet-1.id
  allocation_id = aws_eip.nat_gateway.id
}
resource "aws_route_table" "web" {
  vpc_id = aws_vpc.HelloWorld_vpc_1.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}
resource "aws_route_table_association" "web-1" {
  subnet_id = aws_subnet.web_subnet-1.id
  route_table_id = aws_route_table.web.id
}
resource "aws_route_table_association" "web-2" {
  subnet_id = aws_subnet.web_subnet-2.id
  route_table_id = aws_route_table.web.id
}
resource "aws_route_table_association" "web-3" {
  subnet_id = aws_subnet.web_subnet-3.id
  route_table_id = aws_route_table.web.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.HelloWorld_vpc_1.id
}
resource "aws_default_route_table" "lb" {
  default_route_table_id = aws_vpc.HelloWorld_vpc_1.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

}
resource "aws_subnet" "public_subnet-1" {
  vpc_id            = aws_vpc.HelloWorld_vpc_1.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "us-east-1a"
#  map_public_ip_on_launch = true

}
resource "aws_subnet" "public_subnet-2" {
  vpc_id            = aws_vpc.HelloWorld_vpc_1.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1b"
#  map_public_ip_on_launch = true

}
resource "aws_subnet" "web_subnet-1" {
  vpc_id            = aws_vpc.HelloWorld_vpc_1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
#  map_public_ip_on_launch = true

}

resource "aws_subnet" "web_subnet-2" {
  vpc_id            = aws_vpc.HelloWorld_vpc_1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1c"
#  map_public_ip_on_launch = true
}
resource "aws_subnet" "web_subnet-3" {
  vpc_id            = aws_vpc.HelloWorld_vpc_1.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  #  map_public_ip_on_launch = true
}

#resource "aws_main_route_table_association" "a" {
#  vpc_id         = aws_vpc.HelloWorld_vpc_1.id
#  route_table_id = aws_route_table.lb.id
#}


# resource "aws_security_group" "hello_world-sg" {
#   name   = "hello_world-sg"
#   vpc_id = aws_vpc.HelloWorld_vpc_1.id

#   ingress {
#     description = "Allow Inbound to 22"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#  #   cidr_blocks = ["156.249.11.137/32"]
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   ingress {
#     description = "Allow Inbound to 80"
#     from_port   = local.app_port
#     to_port     = local.app_port
#     protocol    = "tcp"
#     #   cidr_blocks = ["156.249.11.137/32"]
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   #Outgoing traffic
#   egress {
#     from_port   = 0
#     protocol    = "-1"
#     to_port     = 0
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# }

resource "aws_security_group" "lb_sg" {
  name   = "lb_sg"
  vpc_id = aws_vpc.HelloWorld_vpc_1.id

#   ingress {
#     description = "Allow Inbound to 22"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#  #   cidr_blocks = ["156.249.11.137/32"]
#     cidr_blocks = ["0.0.0.0/0"]
#   }
  ingress {
    description = "Allow Inbound to 80"
    from_port   = local.app_port
    to_port     = local.app_port
    protocol    = "tcp"
    #   cidr_blocks = ["156.249.11.137/32"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  #Outgoing traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# resource "aws_s3_bucket" "lb_logs" {
#     bucket = "lb-logs"
# }

# resource "aws_s3_bucket_acl" "lb_logs_bucket_acl" {
#   bucket = aws_s3_bucket.lb_logs.id
#   acl    = "private"
# }
resource "aws_lb" "front_end" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet-1.id,aws_subnet.public_subnet-2.id]
  enable_deletion_protection = false

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }

  #tags = {
  #  Environment = "production"
  #}
}

resource "aws_lb_target_group" "frontend" {
  name     = "frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.HelloWorld_vpc_1.id
}
#  resource "aws_lb_target_group_attachment" "front_end" {
#    target_group_arn = aws_lb_target_group.front_end.arn
#    target_id        = aws_instance.hello_world-1.id
#    port             = 80
#  }

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.web-asg.id
  lb_target_group_arn    = aws_lb_target_group.frontend.arn
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}


resource "aws_launch_configuration" "web" {
  name_prefix          = "web-asg-"
  image_id             = "ami-02f3f602d23f1659d"
  instance_type        = "t2.micro"
  user_data            = file("user-data.sh")
  security_groups      = [aws_security_group.lb_sg.id]
  enable_monitoring    = true
  iam_instance_profile = aws_iam_instance_profile.dev-resources-iam-profile.name
#  associate_public_ip_address = true
#  key_name               = "ssh-key"
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_autoscaling_group" "web-asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  launch_configuration = aws_launch_configuration.web.name
  vpc_zone_identifier  = [aws_subnet.web_subnet-1.id, aws_subnet.web_subnet-2.id, aws_subnet.web_subnet-3.id]
#  target_group_arns    = [aws_lb_target_group.frontend.arn]
}

#scale down at 1800 Singapore Time (1000 UTC)
resource "aws_autoscaling_schedule" "scale_down" {
  scheduled_action_name  = "scale_down"
  min_size               = 0
  max_size               = 0
  desired_capacity       = 0
  recurrence             = "0 10 * * *"
  autoscaling_group_name = aws_autoscaling_group.web-asg.name
}

#Scale up at 0700 Singapore Time Mon-Fri (2300 UTC Sun-Thu)
#Service should stay down during weekends
resource "aws_autoscaling_schedule" "scale_up" {
  scheduled_action_name  = "scale_up"
  min_size               = 1
  max_size               = 3
  desired_capacity       = 1
  recurrence             = "0 23 * * 0,1,2,3,4"
  autoscaling_group_name = aws_autoscaling_group.web-asg.name
}

resource "aws_autoscaling_attachment" "web" {
  autoscaling_group_name = aws_autoscaling_group.web-asg.id
  lb_target_group_arn    = aws_lb_target_group.frontend.arn
}
# resource "aws_instance" "hello_world-1" {
#   ami                    = "ami-02f3f602d23f1659d"
#   instance_type          = "t2.micro"
#   key_name               = "ssh-key"
#   vpc_security_group_ids = [aws_security_group.hello_world-sg.id]
#   subnet_id              = aws_subnet.web_subnet-1.id

#   provisioner "remote-exec" {

#     connection {
#       type        = "ssh"
#       user        = "ec2-user"
#       private_key = file("~/.ssh/id_rsa2")
#       host        = self.public_ip
#     }
#     inline = [
#       "sudo yum install -y nginx",
#       "sudo systemctl start nginx",
#     ]


#   }
# }