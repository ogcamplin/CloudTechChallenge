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
  db_config = var.db_config
}

resource "aws_vpc_endpoint" "s3" {
  vpc_endpoint_type = "Gateway"
  vpc_id = module.networking.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.application.id]
}

resource "aws_vpc_endpoint" "interface" {
  for_each = {
    ecr_dkr = "com.amazonaws.${var.aws_region}.ecr.dkr"
    ecr_api = "com.amazonaws.${var.aws_region}.ecr.api"
    cloudwatch_logs = "com.amazonaws.${var.aws_region}.logs"
  }
  
  vpc_endpoint_type = "Interface"
  vpc_id = module.networking.vpc_id
  service_name = each.value
  security_group_ids = [module.security_groups.ids["vpce"]]
  subnet_ids = module.networking.application_subnet_ids
  private_dns_enabled = true
}

resource "aws_route_table" "application" {
  vpc_id = module.networking.vpc_id
}

resource "aws_route_table_association" "application" {
  count = length(module.networking.application_subnet_ids)
  subnet_id = module.networking.application_subnet_ids[count.index]
  route_table_id = aws_route_table.application.id
}

# module "cloudtechchallenge_database" {
#   source = "terraform-aws-modules/rds/aws"
#   identifier = "cloudtechchallenge-db"
#   engine = var.db_config["db_type"]
#   allocated_storage = 5

#   db_name = var.db_config["db_name"]
#   username = var.db_config["db_user"]
#   password = var.db_config["db_password"]
#   port = var.db_config["db_port"]
#   storage_encrypted = false
#   publicly_accessible = false
  
#   instance_class = "db.t3.micro"

#   iam_database_authentication_enabled = false
#   create_db_subnet_group = true
#   subnet_ids = module.networking.database_subnet_ids

#   vpc_security_group_ids = module.security_groups.ids["database"]
#   create_db_parameter_group = false
# }

locals {
  app_env_config = merge(
    {
      db_host = "10.0.1.5" # module.database.db_instance_address,
      listen_host = "0.0.0.0",
      listen_port = var.app_port
      container_name = "${var.application_name}-container"
    },
    var.db_config,
  )
}

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
      name_prefix = "ctc"
      protocol = "HTTP"
      port = local.app_env_config["listen_port"]
      target_type = "ip"
      health_check = {
        path = "/" # TODO: change to actual healthcheck
      }
      create_attachment = false
    }
  }
}

module "cloudtechchallenge_ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"
  cluster_name = "${var.application_name}-application-cluster"
  create_cloudwatch_log_group = false

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        base = 2
        weight = 100
      }
    }
  }

  services = {
    var.application_name = {
      cpu = 512
      memory = 1024
      enable_execute_command = true

      container_definitions = {
        local.app_env_config["container_name"] = {
          name = local.app_env_config["container_name"]
          image = "726363461405.dkr.ecr.${var.aws_region}.amazonaws.com/ogc-cloudtechchallenge-private:latest"
          port_mappings = [
            { containerPort = local.app_env_config["listen_port"], hostPort = local.app_env_config["listen_port"], protocol = "tcp"}
          ]

          enable_cloudwatch_logging = true
          log_configuration = {
            logDriver = "awslogs",
            options= {
              awslogs-group = "/aws/ecs/${var.application_name}/${local.app_env_config["container_name"]}",
              awslogs-region = var.aws_region
            }
          }

          environment = [
            { name = "VTT_DBUSER", value = local.app_env_config["db_user"] },
            { name = "VTT_DBPASSWORD", value = local.app_env_config["db_password"] },
            { name = "VTT_DBNAME", value = local.app_env_config["db_name"] },
            { name = "VTT_DBPORT", value = local.app_env_config["db_port"] },
            { name = "VTT_DBHOST", value = local.app_env_config["db_host"] },
            { name = "VTT_DBTYPE", value = local.app_env_config["db_type"] },
            { name = "VTT_LISTENHOST", value = local.app_env_config["listen_host"] },
            { name = "VTT_LISTENPORT", value = local.app_env_config["listen_port"] },
          ]
        }
      }
      network_mode = "awsvpc"
      subnet_ids = module.networking.application_subnet_ids
      security_group_ids = [module.security_groups.ids["application"]]
      create_security_group = false

      load_balancer = {
        service = {
          target_group_arn = module.cloudtechchallenge_alb.target_groups["ecs_target_group"].arn
          container_name   = local.app_env_config["container_name"]
          container_port   = local.app_env_config["listen_port"]
        }
      }
    }
  }
}

