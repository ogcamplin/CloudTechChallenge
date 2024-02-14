data "aws_ssm_parameter" "db_username" {
  name = "/cloudtechchallenge/db/username"
}

data "aws_ssm_parameter" "db_password" {
  name = "/cloudtechchallenge/db/password"
  with_decryption = true
}