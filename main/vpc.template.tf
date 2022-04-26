
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zone_a = data.aws_availability_zones.available.names[0]
  availability_zone_b = data.aws_availability_zones.available.names[1]
  availability_zone_c = data.aws_availability_zones.available.names[0]
  availability_zone_d = data.aws_availability_zones.available.names[1]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "simple-example"
  cidr = var.vpc_CIDR_block

  azs             = ["${var.region}a", "${var.region}b"]
  private_subnets = [var.private_subnet_a_CIDR_block, var.private_subnet_b_CIDR_block]
  public_subnets  = [var.public_subnet_a_CIDR_block, var.public_subnet_b_CIDR_block]
  enable_ipv6 = var.enable_ipv6
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  public_subnet_tags = var.tags

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = var.tags
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_CIDR_block
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.dns_support
  enable_dns_hostnames = var.dns_hostnames
  tags = var.tags
}

locals {
  vpc_id = module.vpc.vpc_id
}

# output the vpc ids
output "vpc_id" {
  value = local.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "default_security_group_id" {
  value = module.vpc.default_security_group_id
}