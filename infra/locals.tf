locals {
  app_env_config = {
    listen_host = "0.0.0.0",
    listen_port = var.app_port,
    db_host = module.cloudtechchallenge_database.db_instance_address,
    db_name = module.cloudtechchallenge_database.db_instance_name,
    db_type = module.cloudtechchallenge_database.db_instance_engine,
    db_port = var.db_port
  }
}