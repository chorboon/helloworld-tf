#!/bin/sh
#
sudo yum install -y amazon-ssm-agent
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl start amazon-ssm-agent
