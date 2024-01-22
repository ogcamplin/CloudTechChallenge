module "networking" {
  source         = "./modules/networking"
  vpc_cidr_block = var.vpc_cidr_block
  azs            = var.azs
  aws_region     = var.aws_region
}

module "security_groups" {
  source    = "./modules/security_groups"
  vpc_id    = module.networking.vpc_id
  db_config = var.db_config
}

locals {
  app_env_config = merge(
    {
      db_host = "10.0.5.1",
      listen_host = var.vpc_cidr_block,
      listen_port = 3000
    },
    var.db_config
  )
}

module "ecs_cluster" {
  source             = "./modules/compute"
  db_config          = var.db_config
  subnet_ids         = module.networking.database_subnet_ids
  security_group_ids = [module.security_groups.security_groups["database"]]
  vpc_cidr_block = var.vpc_cidr_block
  db_host = "10.0.5.1"
  app_env_config = local.app_env_config
}

# module "database" {
#   source             = "./modules/database"
#   db_config          = var.db_config
#   subnet_ids         = module.networking.database_subnet_ids
#   security_group_ids = [module.security_groups.security_groups["database"]]
<<<<<<< HEAD
# }
=======
# }
>>>>>>> 830a761 (Add compute + refactor)
