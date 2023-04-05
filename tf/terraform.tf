#create a VPC
resource "aws_vpc" "vpc_sugar"{
	cidr_block = "172.0.0.0/16"
	tags = {
		Name = "vpc_sugar"
	}
}

#Create 2 subnet
resource "aws_subnet" "subnet_sugar"{
	cidr_block = "172.0.1.0/24"
	vpc_id = aws_vpc.vpc_sugar.id	
	tags = {
		Name = "Subnet_sugar"
	}
}


resource "aws_subnet" "subnet_sugar_1"{
        cidr_block = "172.0.2.0/24"
        vpc_id = aws_vpc.vpc_sugar.id
        tags = {
                Name = "Subnet_sugar"
        }
}

#Internet gateway
resource "aws_internet_gateway" "sugar_igw"{
        vpc_id = aws_vpc.vpc_sugar.id
        tags = {
                Name = "sugar_igw"
        }
}

#Route table for the internet gateway
resource "aws_route_table" "rt"{
	vpc_id = aws_vpc.vpc_sugar.id
	route{
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.sugar_igw.id
	}
}


#Associate the subnets to the route table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_sugar.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet_sugar_1.id
  route_table_id = aws_route_table.rt.id
}

#Security group for master instance
resource "aws_security_group" "ec2_master_sg"{
	name_prefix = "Sugar_ec2_sg_Master"
	vpc_id = aws_vpc.vpc_sugar.id
	ingress{
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["70.120.100.125/32","72.181.11.222/32" , "24.242.173.10/32","172.0.1.0/24"]
	}
	ingress{
		from_port= 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
}
	ingress {
                from_port= 443
                to_port = 443
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
}
	egress{
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

#Security group for slave instance
resource "aws_security_group" "ec2_slave_sg"{
        name_prefix = "Sugar_ec2_sg_slave"
	vpc_id = aws_vpc.vpc_sugar.id
        ingress{
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["70.120.100.125/32", "72.181.11.222/32", "24.242.173.10/32","172.0.1.0/24"]
        }

	ingress{
                from_port = 22
                to_port = 22
                protocol = "tcp"
		security_groups = [aws_security_group.ec2_master_sg.id]
}
	ingress{
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["${aws_instance.ec2_sugar_master.private_ip}/32", "${aws_instance.ec2_sugar_master.public_ip}/32"]
}
        ingress{
                from_port= 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
}
        ingress {
                from_port= 443
                to_port = 443
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
}
        egress{
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
}


#Creating EC2 instances
resource "aws_instance" "ec2_sugar_master"{
        ami = "ami-0aa7d40eeae50c9a9"
        instance_type = "t2.medium"
        key_name = "sagartest"
        vpc_security_group_ids = [aws_security_group.ec2_master_sg.id]
	subnet_id = aws_subnet.subnet_sugar.id
	associate_public_ip_address = true
	depends_on = [aws_security_group.ec2_master_sg]

        user_data     = <<-EOF
                #!/bin/bash
                echo "Installing Ansible"
   		sudo yum update -y
                sudo amazon-linux-extras install -y ansible2
		sudo yum install -y docker
                sudo service docker start
                sudo usermod -a -G docker ec2-user
                sudo yum install -y python3-pip
                sudo pip3 install docker-compose
                sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
                sudo install minikube-linux-amd64 /usr/local/bin/minikube
                sudo curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubeadm
                sudo install -o root -g root -m 0755 kubeadm /usr/local/bin/kubeadm
        	mkdir -p /home/ec2-user/.ssh
    		echo "${file("/home/ec2-user/my_devops_playground/tf/mykeys_ssh.pub")}" > /home/ec2-user/.ssh/authorized_keys
    		chmod 700 /home/ec2-user/.ssh
    		chmod 600 /home/ec2-user/.ssh/authorized_keys
		echo "${file("/home/ec2-user/my_devops_playground/tf/mykeys_ssh")}" > /home/ec2-user/mykeys_ssh
		chmod 600 /home/ec2-user/mykeys_ssh
		chown ec2-user:ec2-user mykeys_ssh

	       EOF
        tags = {
                Name = "Master"
        }
	
#	provisioner "remote-exec" {
#    inline = [
#      "sudo hostnamectl set-hostname master",
#    ]
#  }

}

resource "aws_instance" "ec2_sugar_slave"{
        count = 2
        ami = "ami-0aa7d40eeae50c9a9"
        instance_type = "t2.medium"
        key_name = "sagartest"
        vpc_security_group_ids = [aws_security_group.ec2_slave_sg.id]
        subnet_id = aws_subnet.subnet_sugar_1.id
	associate_public_ip_address = true
	depends_on = [aws_security_group.ec2_slave_sg]

	user_data     = <<-EOF
                #!/bin/bash
                echo "Installing Ansible"
                sudo yum update -y
                sudo amazon-linux-extras install -y ansible2
                sudo yum install -y docker
                sudo service docker start
                sudo usermod -a -G docker ec2-user
                sudo yum install -y python3-pip
                sudo pip3 install docker-compose
                sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
                sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
                sudo install minikube-linux-amd64 /usr/local/bin/minikube
                sudo curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubeadm
                sudo install -o root -g root -m 0755 kubeadm /usr/local/bin/kubeadm
                mkdir -p /home/ec2-user/.ssh
                echo "${file("/home/ec2-user/my_devops_playground/tf/mykeys_ssh.pub")}" > /home/ec2-user/.ssh/authorized_keys
                chmod 700 /home/ec2-user/.ssh
                chmod 600 /home/ec2-user/.ssh/authorized_keys
                echo "${file("/home/ec2-user/my_devops_playground/tf/mykeys_ssh")}" > /home/ec2-user/mykeys_ssh
                sudo chmod 600 /home/ec2-user/mykeys_ssh
                sudo chown ec2-user:ec2-user mykeys_ssh
               EOF
        tags = {
                Name = var.instance_tags[count.index]
        }

#	provisioner "remote-exec" {
#    inline = [
#      "sudo hostnamectl set-hostname ${var.instance_tags[count.index]}"
#    ]
#  }

}

#Define instance tags - Name and instance types
variable "instance_tags"{
	type = list(string)
	description = "List of names for ec2 instance"
	default = ["Slave1", "Slave2"]
}


#Output instance details
output "instance_master" {
  description = "The public ip's and instance ids of EC2 instances"
  value = aws_instance.ec2_sugar_master.id
}

output "instance_master1" {
  description = "The public ip's and instance ids of EC2 instances"
  value = aws_instance.ec2_sugar_master.public_ip
}

output "instance_slave" {
  description = "The public ip's and instance ids of EC2 instances"
  value = [
	for instance in aws_instance.ec2_sugar_slave:
	{
		id = instance.id
		ip = instance.public_ip
	}
	]
}
