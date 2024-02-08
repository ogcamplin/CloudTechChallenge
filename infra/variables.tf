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
  description = "AZs to deploy subnets to"
}

variable "app_port" {
  type = number
  description = "Port that the application listens on"
}

variable "db_config" {
  type = object({
    db_port     = number
    db_user     = string
    db_password = string
    db_name     = string
    db_type     = string
  })

  sensitive = true
  description = "Configuration parameters for the RDS database"
}

variable "application_name" {
  type = string
}