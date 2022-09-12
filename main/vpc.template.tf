
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.app}-vpc"
  cidr = var.vpc_CIDR_block

  azs                    = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets        = [var.private_subnet_a_CIDR_block, var.private_subnet_b_CIDR_block]
  public_subnets         = [var.public_subnet_a_CIDR_block, var.public_subnet_b_CIDR_block]
  enable_ipv6            = var.enable_ipv6
  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true
  enable_dns_support     = true

  public_subnet_tags = var.tags

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = var.tags
}

module "vpc_endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]

  endpoints = {
    s3 = {
      # interface endpoint
      service             = "s3"
      tags                = { Name = "s3-vpc-endpoint" }
    },
    cloudwatch = {
      service             = "com.amazonaws.us-east-1.logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecs = {
      service             = "ecs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecs_telemetry = {
      create              = false
      service             = "ecs-telemetry"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
    },
  }

  tags = var.tags
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
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