output "cloudtechchallenge_web_address" {
  value = module.cloudtechchallenge_alb.dns_name
  description = "Address for the application"
}