aws_key           = "{{aws_key}}"
aws_secret        = "{{aws_secret}}"
digger_aws_key    = "{{digger_aws_key}}"
digger_aws_secret = "{{digger_aws_secret}}"
vpc_name          = "{{vpc_name}}"
environment       = "{{environment}}"

{{ 'one_nat_gateway_per_az='+lower(one_nat_gateway_per_az) if one_nat_gateway_per_az is defined else '' }}
{{ 'enable_dns_hostnames='+lower(enable_dns_hostnames) if enable_dns_hostnames is defined else '' }}
{{ 'enable_dns_support='+lower(enable_dns_support) if enable_dns_support is defined else '' }}

region = "{{region}}"

tags = {
  deployed_by = "digger"
  application = "{{vpc_name}}"
  environment = "{{environment}}"
}



