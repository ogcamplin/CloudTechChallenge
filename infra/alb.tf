module "cloudtechchallenge_alb" {
  source = "terraform-aws-modules/alb/aws"
  name = "${var.application_name}-alb"
  vpc_id = module.networking.vpc_id
  subnets = module.networking.web_subnet_ids
  enable_deletion_protection = false
  create_security_group = false
  security_groups = [module.security_groups.ids["alb"]]
  listeners = {
    http = {
      port = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "ecs_target_group"
      }
    }
  }

  target_groups = {
    ecs_target_group = {
      name_prefix = "ecs"
      protocol = "HTTP"
      port = local.app_env_config["listen_port"]
      target_type = "ip"
      health_check = {
        path = "/healthcheck"
      }
      create_attachment = false
    }
  }
}