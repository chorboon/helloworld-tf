# helloworld-tf

ASSUMPTIONS: The user is trying to stay within free-tier or kept as cheap as possible. The AD server may cost money.

This project creates a single VPC with a single internet gateway for public facing services.

An application load balancer is assigned a public IP and an aws_lb_listener listens to port 80, and redirects to a target group, also on port 80.

The ALB spans two public subnets and AZs.

The target group redirects to port 80 of an autoscaling group (ASG) of app servers. 

The app servers uses an aws_launch_configuration to have only have private IP addresses. nginx is provisioned and started using the user-data.sh script to listen to port 80. The ASG spans three private subnet and only has access to the internet via the NAT gateway.

It will scale down to 0 after 6pm SGT and scale up to 1 app server at 8am of weekdays SGT.

A single ec2 instance represents a database server that will not be scaled up or down. It is lazily provisioned with the user-data.sh script, to be changed to use something database specific.

The hard part that got me stuck was enabling SSM agents. The AMI image has the SSM agent installed and running by default, but given the app servers were set up without public IP addresses, a NAT gateway must be set up and added to the default route table of the app server subnet, and the security group must allow outgoing connections to endpoint https://ec2.amazonaws.com . The app servers must also have an IAM profile with Trust relationship set up for ec2.amazonaws.com (see ssm.tf).

The NAT gateway has a public IP, but it must be placed in a subnet that has default routing to the internet via the internet gateway.

The part to add AD was incomplete. The server starts up but not in use. The peculiar challenge here was "dnsIpAddresses" in the aws_ssm_document expects a string but aws_directory_service_directory.ad.dns_ip_addresses supplies a set, and I cannot use [0] to specify an element in the set, even though any element would do. I had to convert it to a list with tolist this way
                   
"dnsIpAddresses": ["${tolist(aws_directory_service_directory.ad.dns_ip_addresses)[0]}"]

terraform.tfvars.json exists but not synced to git as it contains the AD password.

A proof of concept lambda function using python runtime was created. The script to run is lambda.py but archived as lambda.zip. To facilitate this lambda function, Trust relationship was added to the ssm-profile to include lambda.amazonaws.com

Trust relationship to backup.amazonaws.com was also added to facilitate future use of aws_backup

TODO:
Security groups can be tightened, but the subnet routing and lack of public IP addresses offers a measure of isolation for the EC2 instances.


