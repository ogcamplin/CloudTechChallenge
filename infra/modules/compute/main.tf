
# resource "aws_ecs_cluster" "application" {}

# resource "aws_ecs_task_definition" "application" {
#   container_definitions = jsonencode([{
#     environment = [
#       { name = "VTT_DBUSER", value = var.app_env_config["db_user"] },
#       { name = "VTT_DBPASSWORD", value = var.app_env_config["db_password"] },
#       { name = "VTT_DBNAME", value = var.app_env_config["db_name"] },
#       { name = "VTT_DBPORT", value = var.app_env_config["db_port"] },
#       { name = "VTT_DBHOST", value = var.app_env_config["db_host"] },
#       { name = "VTT_DBTYPE", value = var.app_env_config["db_type"] },
#       { name = "VTT_LISTENHOST", value = var.app_env_config["listen_host"] },
#       { name = "VTT_LISTENPORT", value = var.app_env_config["listen_port"] },
#     ],
#     essential = true,
#     image = "resource arn here"
#     portMappings = [
#       { containerPort = var.app_port, hostPort = var.app_port }
#     ]  
#   }])

#   family = "cloudtechchallenge-application-task"
#   memory = 512
#   network_mode = "awsvpc"
# }

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  cluster_name = "cloudtechchallenge-application-cluster"

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        base = 2
        weight = 100
      }
    }
  }

  services = {
    cloudtechchallenge-application = {
      cpu = 512
      memory = 1024

      container_definitions = {
        image = "public.ecr.aws/x6e3r3m8/ogc-cloudtechchallenge-public:latest"
        portMappings = [
          { containerPort = var.app_port, hostPort = var.app_port , protocol = "tcp"}
        ]

        environment = [
          { name = "VTT_DBUSER", value = var.app_env_config["db_user"] },
          { name = "VTT_DBPASSWORD", value = var.app_env_config["db_password"] },
          { name = "VTT_DBNAME", value = var.app_env_config["db_name"] },
          { name = "VTT_DBPORT", value = var.app_env_config["db_port"] },
          { name = "VTT_DBHOST", value = var.app_env_config["db_host"] },
          { name = "VTT_DBTYPE", value = var.app_env_config["db_type"] },
          { name = "VTT_LISTENHOST", value = var.app_env_config["listen_host"] },
          { name = "VTT_LISTENPORT", value = var.app_env_config["listen_port"] },
        ],
      }
      network_mode = "awsvpc"
      subnet_ids = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }
}