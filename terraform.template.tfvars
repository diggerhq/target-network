aws_key = "{{aws_key}}"
aws_secret = "{{aws_secret}}"
digger_aws_key = "{{digger_aws_key}}"
digger_aws_secret = "{{digger_aws_secret}}"
app = "{{app_name}}"
environment = "{{environment}}"

region = "{{region}}"



tags = {
  deployed_by = "digger"
  application   = "{{app_name}}"
  environment   = "{{environment}}"
}

vpc_CIDR_block = "{{environment_config.vpc_CIDR_block}}"
public_subnet_a_CIDR_block = "{{environment_config.public_subnet_a_CIDR_block}}"
public_subnet_b_CIDR_block = "{{environment_config.public_subnet_b_CIDR_block}}"
private_subnet_a_CIDR_block = "{{environment_config.private_subnet_a_CIDR_block}}"
private_subnet_a_CIDR_block = "{{environment_config.private_subnet_a_CIDR_block}}"

