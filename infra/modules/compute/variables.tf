variable "vpc_cidr_block" {}
variable "db_host" {}
variable "db_config" {}

variable "app_port" {
  type = number
  default = 3000
}

variable "app_env_config" {}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}