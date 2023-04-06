#create a VPC
resource "aws_vpc" "vpc_sugar"{
	cidr_block = var.vpc_sugar
	tags = {
		Name = "vpc_sugar"
	}
}

#Create 2 subnet
resource "aws_subnet" "subnet_sugar"{
	cidr_block = var.subnet_sugar_master
	vpc_id = aws_vpc.vpc_sugar.id	
	tags = {
		Name = "Subnet_sugar"
	}
}


resource "aws_subnet" "subnet_sugar_1"{
        cidr_block = var.subnet_sugar_slave
        vpc_id = aws_vpc.vpc_sugar.id
        tags = {
                Name = "Subnet_sugar"
        }
}


#Subnet for RDS
resource "aws_subnet" "subnet_sugar_rds_1"{
        cidr_block = var.subnet_sugar_rds_1
        vpc_id = aws_vpc.vpc_sugar.id
	map_public_ip_on_launch = "false" //it makes private subnet
        tags = {
                Name = "Subnet_sugar_rds_1"
        }
}


resource "aws_subnet" "subnet_sugar_rds_2"{
        cidr_block = var.subnet_sugar_rds_2
        vpc_id = aws_vpc.vpc_sugar.id
	map_public_ip_on_launch = "false" //it makes private subnet
        tags = {
                Name = "Subnet_sugar_rds_2"
        }
}

#Create RDS subnet groups
resource "aws_db_subnet_group" "rds_subnet_grp" {
  subnet_ids = ["${aws_subnet.subnet_sugar_rds_1.id}", "${aws_subnet.subnet_sugar_rds_2.id}"]
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
