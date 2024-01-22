resource "aws_security_group" "alb" {
  vpc_id = var.vpc_id
  name = "alb_sg"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
}

resource "aws_security_group" "application" {
  vpc_id = var.vpc_id
  name = "application_sg"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }
}

resource "aws_security_group" "database" {
  vpc_id = var.vpc_id
  name = "database_sg"

  ingress {
    from_port = var.db_config["db_port"]
    to_port = var.db_config["db_port"]
    protocol = "tcp"
    security_groups = ["${aws_security_group.application.id}"]
  }
}