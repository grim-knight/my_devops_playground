#VPC
output "vpc_sugar"{
	value = aws_vpc.vpc_sugar.id
}

#Subnets
output "subnet_sugar_master"{
        value = aws_subnet.subnet_sugar.id
}

output "subnet_sugar_slave"{
        value = aws_subnet.subnet_sugar_1.id
}

#RDS Subnets

output "subnet_sugar_rds_1"{
        value = aws_subnet.subnet_sugar_rds_1.id
}

output "subnet_sugar_rds_2"{
        value = aws_subnet.subnet_sugar_rds_2.id
}

output "rds_subnet_grp_name"{
	value = aws_db_subnet_group.rds_subnet_grp.name
} 
