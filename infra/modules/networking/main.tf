resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "vpc-${var.aws_region}-${var.application_name}"
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
    Name = "subnet-${var.azs[count.index]}-public-${var.application_name}-alb"
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
    Name = "subnet-${var.azs[count.index]}-private-${var.application_name}-application"
  }
}

resource "aws_subnet" "private_database" {
  vpc_id = aws_vpc.main.id
  count = length(var.azs)

  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index+length(var.azs)*2+1)
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-${var.azs[count.index]}-private-${var.application_name}-database"
  }
}