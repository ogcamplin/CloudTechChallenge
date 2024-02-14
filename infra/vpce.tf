resource "aws_route_table" "s3_vpce" {
  vpc_id = module.networking.vpc_id
}

resource "aws_route_table_association" "s3_vpce" {
  count = length(module.networking.application_subnet_ids)
  subnet_id = module.networking.application_subnet_ids[count.index]
  route_table_id = aws_route_table.s3_vpce.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_endpoint_type = "Gateway"
  vpc_id = module.networking.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = [aws_route_table.s3_vpce.id]
}

resource "aws_vpc_endpoint" "interface" {
  for_each = {
    ecr_dkr = "com.amazonaws.${var.aws_region}.ecr.dkr"
    ecr_api = "com.amazonaws.${var.aws_region}.ecr.api"
    cloudwatch_logs = "com.amazonaws.${var.aws_region}.logs"
    ssm_parameter = "com.amazonaws.${var.aws_region}.ssm"
  }
  
  vpc_endpoint_type = "Interface"
  vpc_id = module.networking.vpc_id
  service_name = each.value
  security_group_ids = [module.security_groups.ids["vpce"]]
  subnet_ids = module.networking.application_subnet_ids
  private_dns_enabled = true
}

