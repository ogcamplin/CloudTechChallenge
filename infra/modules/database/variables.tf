variable "db_config" {
  type = object({
    db_port     = number
    db_user     = string
    db_password = string
    db_name     = string
    db_type     = string
  })
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}