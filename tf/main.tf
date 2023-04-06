#VPC
module "vpc" {
  source              = "./modules/vpc"
  vpc_sugar           = "172.0.0.0/16"
  subnet_sugar_master = "172.0.1.0/24"
  subnet_sugar_slave  = "172.0.2.0/24"
  subnet_sugar_rds_1 = "172.0.3.0/24"
  subnet_sugar_rds_2 = "172.0.4.0/24"
}

module "ec2" {
  source              = "./modules/ec2"
  vpc_sugar           = module.vpc.vpc_sugar
  subnet_sugar_master = module.vpc.subnet_sugar_master
  subnet_sugar_slave  = module.vpc.subnet_sugar_slave
  wordpressdb = module.rds.wordpressdb
  rds_endpoint = module.rds.rds_endpoint
}

module "rds"{
	source = "./modules/rds"
	vpc_sugar           = module.vpc.vpc_sugar
	ec2_master_sg = module.ec2.ec2_master_sg
	ec2_slave_sg = module.ec2.ec2_slave_sg
	rds_subnet_grp_name = module.vpc.rds_subnet_grp_name
	instance_class = "db.t2.micro"
	database_name = "wordpress_db"
	database_user = "wordpress_user"
	database_password = "1234567890"
}
