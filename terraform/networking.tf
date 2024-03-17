#  default vpc
data "aws_vpc" "default" {
  default = true
}

# custom vpc
data "aws_availability_zones" "available" {}

locals {
  azs = data.aws_availability_zones.available.names
}

resource "random_id" "random" {
  byte_length = 2
}

resource "aws_vpc" "mock_server_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "mock-server-vpc-${random_id.random.dec}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "mock_server_internet_gateway" {
  vpc_id = aws_vpc.mock_server_vpc.id

  tags = {
    Name = "mock-server-gateway-${random_id.random.dec}"
  }
}

resource "aws_route_table" "mock_server_public_rt" {
  vpc_id = aws_vpc.mock_server_vpc.id

  tags = {
    Name = "mock-server-public"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mock_server_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mock_server_internet_gateway.id
}

resource "aws_default_route_table" "mock_server_private_rt" {
  default_route_table_id = aws_vpc.mock_server_vpc.default_route_table_id

  tags = {
    Name : "mock-server-private"
  }
}


resource "aws_subnet" "mock_server_public_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.mock_server_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index) # var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = local.azs[count.index]

  tags = {
    Name = "mock-server-public-${count.index + 1}"
  }
}

resource "aws_subnet" "mock_server_private_subnet" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.mock_server_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, length(local.azs) + count.index) # var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = local.azs[count.index]

  tags = {
    Name = "mock-server-private-${count.index + 1}"
  }
}

resource "aws_route_table_association" "mock_server_public_assoc" {
  count = length(local.azs)
  subnet_id = aws_subnet.mock_server_public_subnet[count.index].id
  route_table_id = aws_route_table.mock_server_public_rt.id
}


# Security group
resource "aws_security_group" "mock_sg" {
  name        = "mock_sg"
  description = "Security group for mock server connections support for smtp, smtps, http, https, imap, imaps,etc"
  vpc_id      = aws_vpc.mock_server_vpc.id # data.aws_vpc.default.id

  tags = {
    Name : "mock-server-connections"
  }
}


resource "aws_vpc_security_group_ingress_rule" "ingress_http" {
  security_group_id = aws_security_group.mock_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "ingress_tyk_http" {
  security_group_id = aws_security_group.mock_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8080
  ip_protocol = "tcp"
  to_port     = 8080
}

resource "aws_vpc_security_group_ingress_rule" "ingress_https" {
  security_group_id = aws_security_group.mock_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}


resource "aws_vpc_security_group_ingress_rule" "ingress_ssh" {
  security_group_id = aws_security_group.mock_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}


resource "aws_vpc_security_group_egress_rule" "egress_all" {
  security_group_id = aws_security_group.mock_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
