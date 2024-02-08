resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "vpc-${var.aws_region}-cloudtechchallenge"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_alb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_subnet" "public_alb" {
  vpc_id = aws_vpc.main.id
  count = length(var.azs)

  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index+1)
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.azs[count.index]}-public-cloudtechchallenge-alb"
  }
}

resource "aws_route_table_association" "public_alb" {
  count = length(var.azs)
  subnet_id = aws_subnet.public_alb[count.index].id
  route_table_id = aws_route_table.public_alb.id
}

resource "aws_subnet" "private_application" {
  vpc_id = aws_vpc.main.id
  count = length(var.azs)

  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index+length(var.azs)+1)
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.azs[count.index]}-private-cloudtechchallenge-application"
  }
}

# resource "aws_cloudwatch_log_group" "application" {
#   for_each = toset([ for v in aws_subnet.private_application : v.tags["Name"]])
#   name = "${each.value}-flow-logs"
#   retention_in_days = 1
# }

# resource "aws_flow_log" "application" {
#   for_each = { for v in aws_subnet.private_application : v.tags["Name"] => v}
#   traffic_type = "ALL"
#   log_destination = aws_cloudwatch_log_group.application[each.key].arn
#   log_destination_type = "cloud-watch-logs"
#   iam_role_arn = aws_iam_role.application_flow_log.arn
#   subnet_id = each.value.id
# }

# resource "aws_iam_role" "application_flow_log" {
#   name = "FlowLogCloudWatch"
#   assume_role_policy = data.aws_iam_policy_document.application_flow_log_trust.json
# }

# data "aws_iam_policy_document" "application_flow_log_trust" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["vpc-flow-logs.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# data "aws_iam_policy_document" "application_flow_log" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams",
#     ]

#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy" "application_flow_log" {
#   name   = "FlowLogCloudWatchAccess"
#   role   = aws_iam_role.application_flow_log.id
#   policy = data.aws_iam_policy_document.application_flow_log.json
# }

resource "aws_subnet" "private_database" {
  vpc_id = aws_vpc.main.id
  count = length(var.azs)

  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index+length(var.azs)*2+1)
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.azs[count.index]}-private-cloudtechchallenge-database"
  }
}