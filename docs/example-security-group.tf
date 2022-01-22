######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  An example of how to use the IP lookup functionality of Rawrify to create an EC2 security group that only
  allows SSH access from your public IPv4 address.
*/

variable "my-vpc" {
  description = "VPC ID that the security group should be launched into"
  type = string
}

data "http" "my-ip" {
  url = "https://ipv4.rawrify.com/ip"
}

resource "aws_security_group" "my-ip-access-only" {
  name        = "allow_ssh_my_ip"
  description = "Allow SSH traffic from my IPv4 address"
  vpc_id      = var.my-vpc

  ingress {
    description      = "SSH from my IP"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["${data.http.my-ip.body}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_my_ip"
  }
}