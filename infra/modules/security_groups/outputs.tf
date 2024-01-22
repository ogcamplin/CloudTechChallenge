output "security_groups" {
  value = {
    application = aws_security_group.application.id
    alb = aws_security_group.alb.id
    database = aws_security_group.database.id
  }
}