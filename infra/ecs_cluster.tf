data "aws_ecs_task_execution" "database_init" {
  cluster = module.cloudtechchallenge_ecs_cluster.cluster_id
  task_definition = aws_ecs_task_definition.database_init.arn
  enable_execute_command = true
  launch_type = "FARGATE"

  network_configuration {
    security_groups = [module.security_groups.ids["application"]]
    subnets = module.networking.application_subnet_ids
    assign_public_ip = false
  }
}

resource "aws_ecs_task_definition" "database_init" {
  family = "init-db-task"
  execution_role_arn = module.cloudtechchallenge_ecs_cluster.services["cloudtechchallenge"].task_exec_iam_role_arn
  task_role_arn = module.cloudtechchallenge_ecs_cluster.services["cloudtechchallenge"].tasks_iam_role_arn
  cpu = 256
  memory = 512
  requires_compatibilities = [ "FARGATE" ]
  network_mode = "awsvpc"
  
  container_definitions = jsonencode([
    {
      name      = "init-db-container"
      image     = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/ogc-cloudtechchallenge-private:latest"
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region = var.aws_region
          awslogs-group  = "/aws/ecs/${var.application_name}/application-container"
          awslogs-stream-prefix = "ecs/init-db-task"
        }
      }
      essential = true
      entrypoint = ["./TechChallengeApp", "updatedb", "-s"]
      secrets = [
        { name = "VTT_DBUSER", valueFrom = data.aws_ssm_parameter.db_username.arn },
        { name = "VTT_DBPASSWORD", valueFrom = data.aws_ssm_parameter.db_password.arn }
      ]
      environment = [
        { name = "VTT_DBNAME", value = "${local.app_env_config["db_name"]}" },
        { name = "VTT_DBPORT", value = "${tostring(local.app_env_config["db_port"])}" },
        { name = "VTT_DBHOST", value = "${local.app_env_config["db_host"]}" },
        { name = "VTT_DBTYPE", value = "${local.app_env_config["db_type"]}" },
        { name = "VTT_LISTENHOST", value = "${local.app_env_config["listen_host"]}" },
        { name = "VTT_LISTENPORT", value = "${tostring(local.app_env_config["listen_port"])}" },
      ]
    }
  ])
}

module "cloudtechchallenge_ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"
  cluster_name = "${var.application_name}-application-cluster"
  create_cloudwatch_log_group = false
  task_exec_ssm_param_arns = [
    data.aws_ssm_parameter.db_username.arn,
    data.aws_ssm_parameter.db_password.arn
  ]

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        base = 2
        weight = 100
      }
    }
  }

  services = {
    cloudtechchallenge = {
      cpu = 512
      memory = 1024
      enable_execute_command = true

      container_definitions = {
         application-container = {
          name = "application-container"
          image = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/ogc-cloudtechchallenge-private:latest"
          port_mappings = [
            { containerPort = local.app_env_config["listen_port"], hostPort = local.app_env_config["listen_port"], protocol = "tcp"}
          ]

          enable_cloudwatch_logging = true

          secrets = [
            { name = "VTT_DBUSER", valueFrom = data.aws_ssm_parameter.db_username.arn },
            { name = "VTT_DBPASSWORD", valueFrom = data.aws_ssm_parameter.db_password.arn }
          ]

          environment = [
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
          container_name   = "application-container"
          container_port   = local.app_env_config["listen_port"]
        }
      }
    }
  }
}