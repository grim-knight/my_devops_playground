##Security group for master instance
resource "aws_security_group" "ec2_master_sg"{
	name_prefix = "Sugar_ec2_sg_Master"
	vpc_id = var.vpc_sugar
	ingress{
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["70.120.100.125/32","72.181.11.222/32" , "24.242.173.10/32","172.0.1.0/24", "44.201.57.218/32", "10.1.29.165/32"]
	}
	ingress{
		description = "HTTP"
		from_port= 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
}
	ingress {
		description = "HTTPS"
                from_port= 443
                to_port = 443
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
}
        ingress{
                description = "Mysql"
                from_port = 3306
                to_port = 3306
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
	vpc_id = var.vpc_sugar
        ingress{
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["70.120.100.125/32", "72.181.11.222/32", "24.242.173.10/32","172.0.1.0/24", "44.201.57.218/32", "10.1.29.165/32"]
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
		description = "HTTP"
                from_port= 80
                to_port = 80
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
}
        ingress {
		description = "HTTPS"
                from_port= 443
                to_port = 443
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
}
	ingress{
		description = "Mysql"
		from_port = 3306
		to_port = 3306
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
	subnet_id = var.subnet_sugar_master
	associate_public_ip_address = true
	depends_on = [aws_security_group.ec2_master_sg]


	#depends_on = [var.wordpressdb]
        user_data     = <<-EOF
                #!/bin/bash
                echo "Installing Ansible"
   		sudo yum update -y
		sudo yum install -y httpd php
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
    		echo "${file("/home/ec2-user/my_devops_playground/ansible/modules/ec2/mykeys_ssh.pub")}" > /home/ec2-user/.ssh/authorized_keys
    		chmod 700 /home/ec2-user/.ssh
    		chmod 600 /home/ec2-user/.ssh/authorized_keys
		echo "${file("/home/ec2-user/my_devops_playground/ansible/modules/ec2/mykeys_ssh")}" > /home/ec2-user/mykeys_ssh
		sudo chmod 600 /home/ec2-user/mykeys_ssh
		sudo chown ec2-user:ec2-user /home/ec2-user/mykeys_ssh
			
	       EOF
        tags = {
                Name = "Master"
        }

	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = file("/home/ec2-user/my_devops_playground/ansible/modules/ec2/mykeys_ssh")
		host = self.public_ip
	}
	
	provisioner "remote-exec"{
		inline = [
                "echo 'Hello, SSH success' > success.txt",
		#Ansible Playbook
                "mkdir ansible-files",
                #ansible-inventory.txt
                "echo '${file("/home/ec2-user/my_devops_playground/ansible/modules/ansible_files/ansible-inventory.txt")}' > /home/ec2-user/ansible-files/ansible-inventory.txt",
                #wp-ansible.yml
                "echo '${file("/home/ec2-user/my_devops_playground/ansible/modules/ansible_files/wp-ansible.yml")}' > /home/ec2-user/ansible-files/wp-ansible.yml",
                #wp-config
                "echo '${file("/home/ec2-user/my_devops_playground/ansible/modules/ansible_files/wp-config.php")}' > /home/ec2-user/ansible-files/wp-config.php",
		"cd ansible-files",
		#Running ansible commands
	#	"ansible-playbook -i ansible-inventory.txt wp-ansible.yml"
]
	}
	


}



resource "aws_instance" "ec2_sugar_slave"{
        count = 2
        ami = "ami-0aa7d40eeae50c9a9"
        instance_type = "t2.medium"
        key_name = "sagartest"
        vpc_security_group_ids = [aws_security_group.ec2_slave_sg.id]
        subnet_id = var.subnet_sugar_slave
	associate_public_ip_address = true
	depends_on = [aws_security_group.ec2_slave_sg]

	user_data     = <<-EOF
                #!/bin/bash
                echo "Installing Ansible"
                sudo yum update -y
		sudo yum install -y httpd php
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
                echo "${file("/home/ec2-user/my_devops_playground/tf/modules/ec2/mykeys_ssh.pub")}" > /home/ec2-user/.ssh/authorized_keys
                chmod 700 /home/ec2-user/.ssh
                chmod 600 /home/ec2-user/.ssh/authorized_keys
                echo "${file("/home/ec2-user/my_devops_playground/tf/modules/ec2/mykeys_ssh")}" > /home/ec2-user/mykeys_ssh
                sudo chmod 600 /home/ec2-user/mykeys_ssh
                sudo chown ec2-user:ec2-user /home/ec2-user/mykeys_ssh
               EOF
        tags = {
                Name = var.instance_tags[count.index]
       }

}
