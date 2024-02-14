module "cloudtechchallenge_database" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "${var.application_name}-db"
  instance_class = "db.t3.micro"
  engine = "postgres"
  family = "postgres15"
  parameters = [{
    name = "rds.force_ssl"
    value = "0"
  }]
  parameter_group_name = "${var.application_name}"


  create_db_parameter_group = true
  allocated_storage = 5

  db_name = "${var.application_name}"
  username = data.aws_ssm_parameter.db_username.value
  password = data.aws_ssm_parameter.db_password.value
  manage_master_user_password = false
  port = 5432
  storage_encrypted = false
  publicly_accessible = false
  iam_database_authentication_enabled = false

  create_db_subnet_group = true
  subnet_ids = module.networking.database_subnet_ids
  vpc_security_group_ids = [module.security_groups.ids["database"]]
}