variable "vpc_id" {}
variable "db_config" {}

resource "aws_security_group" "alb" {
  vpc_id = var.vpc_id
  name = "alb_sg"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "application" {
  vpc_id = var.vpc_id
  name = "application_sg"

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.alb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpce" {
  vpc_id = var.vpc_id
  name = "vpce_sg"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    security_groups = ["${aws_security_group.application.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ids" {
  value = {
    application = aws_security_group.application.id
    alb = aws_security_group.alb.id
    database = aws_security_group.database.id
    vpce = aws_security_group.vpce.id
  }
}