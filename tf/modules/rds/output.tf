#RDS instance endpoint
output "rds_endpoint"{
	value = aws_db_instance.wordpressdb.endpoint
}

output "wordpressdb"{
	value = aws_db_instance.wordpressdb.name
}
