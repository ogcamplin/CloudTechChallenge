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

variable "account_id" {
  type = number
}

variable "application_name" {
  type = string
}

variable "db_port" {
  type = number
  default = 5432
}