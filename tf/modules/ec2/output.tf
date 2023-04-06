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


output "ec2_master_sg"{
	value = aws_security_group.ec2_master_sg.id
}

output "ec2_slave_sg"{
	value = aws_security_group.ec2_slave_sg.id
}
