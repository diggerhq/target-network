
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zone_a = data.aws_availability_zones.available.names[0]
  availability_zone_b = data.aws_availability_zones.available.names[1]
  availability_zone_c = data.aws_availability_zones.available.names[0]
  availability_zone_d = data.aws_availability_zones.available.names[1]
}


# this config allows creating subbnets in an existing VPC
{% if environment_config.vpc_id %}
data "aws_vpc" "vpc" {
  id = "{{environment_config.vpc_id}}"
}

locals {
  vpc = data.aws_vpc.vpc
}
{% else %}
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_CIDR_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.dns_support
  enable_dns_hostnames = var.dns_hostnames
  tags = var.tags
}

locals {
  vpc = aws_vpc.vpc
}
{% endif %}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.public_subnet_a_CIDR_block
  map_public_ip_on_launch = true
  availability_zone       = local.availability_zone_a
  tags = {
    Name = "${var.app}-${var.environment}-public_vpc_subneta"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.public_subnet_b_CIDR_block
  map_public_ip_on_launch = true
  availability_zone       = local.availability_zone_b
  tags = {
    Name = "${var.app}-${var.environment}-public_vpc_subnetb"
  }
}

resource "aws_subnet" "public_subnet_c" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.public_subnet_c_CIDR_block
  map_public_ip_on_launch = true
  availability_zone       = local.availability_zone_c
  tags = {
    Name = "${var.app}-${var.environment}-public_vpc_subnetc"
  }
}

resource "aws_subnet" "public_subnet_d" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.public_subnet_d_CIDR_block
  map_public_ip_on_launch = true
  availability_zone       = local.availability_zone_d
  tags = {
    Name = "${var.app}-${var.environment}-public_vpc_subnetd"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.private_subnet_a_CIDR_block
  map_public_ip_on_launch = false
  availability_zone       = local.availability_zone_a
  tags = {
    Name = "${var.app}-${var.environment}-private_vpc_subneta"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = local.vpc.id
  cidr_block              = var.private_subnet_b_CIDR_block
  map_public_ip_on_launch = false
  availability_zone       = local.availability_zone_b
  tags = {
    Name = "${var.app}-${var.environment}-private_vpc_subnetb"
  }
}

# if user is attaching to existing VPC we assume they already have a gateway attached!
{% if environment_config.vpc_id %}
  data "aws_internet_gateway" "vpc_ig" {
    filter {
      # filter by vpc ID
      name   = "attachment.vpc-id"
      values = ["{{environment_config.vpc_id}}"]
    }
  }

  locals {
    vpc_ig = data.aws_internet_gateway.vpc_ig
  }
{% else %}
  resource "aws_internet_gateway" "vpc_ig" {
    vpc_id = local.vpc.id
    tags = {
      Name = "${var.app} Internet Gateway"
    }
  }

  locals {
    vpc_ig = aws_internet_gateway.vpc_ig
  }
{% endif %}

resource "aws_route_table" "route_table_public" {
  vpc_id = local.vpc.id

  # Note: "local" VPC record is implicitly specified
  tags = {
    Name = "${var.app}-${var.environment} Public Route Table"
  }
}

resource "aws_route" "gateway_route" {
  route_table_id = aws_route_table.route_table_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = local.vpc_ig.id
}

resource "aws_route_table_association" "publica" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "publicb" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "publicc" {
  subnet_id      = aws_subnet.public_subnet_c.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "publicd" {
  subnet_id      = aws_subnet.public_subnet_d.id
  route_table_id = aws_route_table.route_table_public.id
}

# output the vpc ids
output "vpc_id" {
  value = local.vpc.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
}

output "public_subnet_c_id" {
  value = aws_subnet.public_subnet_c.id
}

output "public_subnet_d_id" {
  value = aws_subnet.public_subnet_d.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

{%- if environment_config.use_subnets_cd %}
output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id, aws_subnet.public_subnet_c.id, aws_subnet.public_subnet_d.id]
}
{% else %}
output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}
{% endif %}
