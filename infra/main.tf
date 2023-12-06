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

module "database" {
  source             = "./modules/database"
  db_config          = var.db_config
  subnet_ids         = module.networking.database_subnet_ids
  security_group_ids = [module.security_groups.security_groups["database"]]
}