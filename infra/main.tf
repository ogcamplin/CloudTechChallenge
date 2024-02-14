module "networking" {
  source         = "./modules/networking"
  vpc_cidr_block = var.vpc_cidr_block
  azs            = var.azs
  aws_region     = var.aws_region
  application_name = var.application_name
}

module "security_groups" {
  source    = "./modules/security_groups"
  vpc_id    = module.networking.vpc_id
  db_port = var.db_port
  app_port = var.app_port
}



