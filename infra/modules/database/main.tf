# resource "aws_db_instance" "primary" {
#   engine = var.db_config["db_type"]
#   username = var.db_config["db_user"]
#   port = var.db_config["db_port"]
# }

module "database" {
  
  source = "terraform-aws-modules/rds/aws"
  identifier = "cloudtechchallenge-db"
  engine = var.db_config["db_type"]
  allocated_storage = 5

  db_name = var.db_config["db_name"]
  username = var.db_config["db_user"]
  password = var.db_config["db_password"]
  port = var.db_config["db_port"]
  storage_encrypted = false
  publicly_accessible = false
  
  instance_class = "db.t3.micro"

  iam_database_authentication_enabled = false
  create_db_subnet_group = true
  subnet_ids = var.subnet_ids

  vpc_security_group_ids = var.security_group_ids
  create_db_parameter_group = false
}