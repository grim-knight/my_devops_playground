provider "aws"{
	region = "us-east-1"
}

resource "aws_vpc" "vpc_sugar"{
	cidr_block = "172.0.0.0/16"
	tags = {
		Name = "vpc_sugar"
	}
}

resource "aws_subnet" "subnet_sugar"{
	cidr_block = "172.0.1.0/24"
	vpc_id = aws_vpc.vpc_sugar.id	
	tags = {
		Name = "Subnet_sugar"
	}
}

resource "aws_security_group" "ec2_sg"{
	name_prefix = "Sugar_ec2_sg_1"
	ingress{
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["70.120.100.125/32"]
	}
	egress{
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}


#Create EC2 instance
resource "aws_instance" "ec2_sugar"{
	count = 3
	ami = "ami-0aa7d40eeae50c9a9"
#	instance_type = var.instance_type[count.index]
	instance_type = "t2.medium"
	key_name = "sagartest"
	vpc_security_group_ids = [aws_security_group.ec2_sg.id]
	user_data     = <<-EOF
   		#!/bin/bash
    		echo "Installing Ansible"
    		sudo amazon-linux-extras install -y ansible2
    		EOF
	tags = {
		Name = var.instance_tags[count.index]
	}
}


#Define instance tags - Name and instance types
variable "instance_tags"{
	type = list(string)
	description = "List of names for ec2 instance"
	default = ["master", "slave1", "slave2"]
}

variable "instance_type"{
	type = list(string)
	description = "List of instance types"
	default = ["t2.medium", "t2.micro", "t2.micro"]
}


#Output instance IPs 
output "instance__ids_ips" {
  value = [
	for instance in aws_instance.ec2_sugar :
	{
		id = instance.id
		ip = instance.public_ip
	}
	]
}


