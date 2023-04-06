variable "vpc_sugar"{
	type = string
}
variable "ec2_master_sg"{
	type = string
}

variable "ec2_slave_sg"{
	type = string
}

variable "rds_subnet_grp_name"{
	type = string
}

variable "instance_class"{
	type = string
}

variable "database_name"{
	type = string
}

variable "database_user"{
	type = string
}

variable "database_password"{
	type = string
}
