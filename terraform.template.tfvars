aws_key           = "{{aws_key}}"
aws_secret        = "{{aws_secret}}"
digger_aws_key    = "{{digger_aws_key}}"
digger_aws_secret = "{{digger_aws_secret}}"
environment       = "{{environment}}"
network_name      = "{{network_name}}"

{{ 'one_nat_gateway_per_az='+one_nat_gateway_per_az | lower if one_nat_gateway_per_az is defined else '' }}
{{ 'enable_dns_hostnames='+enable_dns_hostnames | lower if enable_dns_hostnames is defined else '' }}
{{ 'enable_dns_support='+enable_dns_support | lower if enable_dns_support is defined else '' }}
{{ 'enable_nat_gateway='+enable_nat_gateway | lower if enable_nat_gateway is defined else '' }}

region = "{{region}}"

tags = {
  deployed_by = "digger"
  digger-target = "target-network"
}



