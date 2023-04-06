#variables 
#Define instance tags - Name and instance types
variable "instance_tags"{
	type = list(string)
	description = "List of names for ec2 instance"
	default = ["Slave1", "Slave2"]
}

variable "vpc_sugar"{
	type = string
}

variable "subnet_sugar_master"{
	type = string
}

variable "subnet_sugar_slave"{
	type = string
}

variable "wordpressdb"{
	type = string
}

variable "rds_endpoint"{
	type = string
}
