# Security group for RDS
resource "aws_security_group" "rds_sugar_allow_rule" {
  vpc_id = var.vpc_sugar
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_master_sg, var.ec2_slave_sg]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "rds to allow ec2"
  }

}

# Create RDS instance
resource "aws_db_instance" "wordpressdb" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.instance_class
  db_subnet_group_name   = var.rds_subnet_grp_name
  vpc_security_group_ids = [aws_security_group.rds_sugar_allow_rule.id]
  db_name                   = var.database_name
  username               = var.database_user
  password               = var.database_password
  skip_final_snapshot    = true
}

# change USERDATA varible value after grabbing RDS endpoint info
#data "template_file" "playbook" {
#  template = file("${/home/ec2-user/my_devops_playground/tf/modules/rds}/wp_playbook.yml")
#  vars = {
#    db_username      = "${var.database_user}"
#    db_user_password = "${var.database_password}"
#    db_name          = "${var.database_name}"
#    db_RDS           = "${aws_db_instance.wordpressdb.endpoint}"
#  }
#}
