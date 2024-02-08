variable "aws_region" {
  type        = string
  default     = "ap-southeast-2"
  description = "AWS Deployment Region"
}

variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]
  description = "AZs to deploy subnets to"
}

variable "app_port" {
  type = number
  default = 3000
}

variable "db_config" {
  type = object({
    db_port     = number
    db_user     = string
    db_password = string
    db_name     = string
    db_type     = string
  })

  default = {
    db_port     = "5432"
    db_user     = "postgres"
    db_password = "changeme"
    db_type     = "postgres"
    db_name     = "app"
  }

  sensitive = true

  description = "Configuration parameters for the RDS database"
}