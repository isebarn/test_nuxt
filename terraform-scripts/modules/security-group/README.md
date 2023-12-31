## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.20.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.egress-source-sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.source-sg-tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.source-sg-udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ssh_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_egress_rule"></a> [create\_egress\_rule](#input\_create\_egress\_rule) | Whether to egress rule for security group created | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Whether to create security group | `bool` | `true` | no |
| <a name="input_egress_cidr_blocks"></a> [egress\_cidr\_blocks](#input\_egress\_cidr\_blocks) | List of the cidr range blocks for security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_egress_port"></a> [egress\_port](#input\_egress\_port) | List of Ports for egress rule | `list(number)` | <pre>[<br>  0<br>]</pre> | no |
| <a name="input_egress_source_security_group_ids"></a> [egress\_source\_security\_group\_ids](#input\_egress\_source\_security\_group\_ids) | List of source security ids for egress rule | `list(string)` | `[]` | no |
| <a name="input_ingress_tcp_source_security_group_ids"></a> [ingress\_tcp\_source\_security\_group\_ids](#input\_ingress\_tcp\_source\_security\_group\_ids) | List of source security ids for ingress tcp rule | `list(string)` | `[]` | no |
| <a name="input_ingress_udp_source_security_group_ids"></a> [ingress\_udp\_source\_security\_group\_ids](#input\_ingress\_udp\_source\_security\_group\_ids) | List of source security ids for ingress udp rule | `list(string)` | `[]` | no |
| <a name="input_myip_ssh"></a> [myip\_ssh](#input\_myip\_ssh) | List of IP address for ssh connection. If no SSH needed, just leave it | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on Security group created | `string` | `null` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Id of a Security group. Only need when 'security\_group\_id' is set to false | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `null` | no |
| <a name="input_tcp_cidr_blocks"></a> [tcp\_cidr\_blocks](#input\_tcp\_cidr\_blocks) | List of the cidr range blocks for security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_tcp_ports"></a> [tcp\_ports](#input\_tcp\_ports) | List of TCP ports in Security group | `list(number)` | `[]` | no |
| <a name="input_udp_cidr_blocks"></a> [udp\_cidr\_blocks](#input\_udp\_cidr\_blocks) | List of the cidr range blocks for security group | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_udp_ports"></a> [udp\_ports](#input\_udp\_ports) | List of UDP ports in Security group | `list(number)` | `[]` | no |
| <a name="input_vpc_description"></a> [vpc\_description](#input\_vpc\_description) | Description for VPC | `string` | `"VPC created by terraform"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of vpc. Need only if you want to create in a custom vpc | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_group"></a> [security\_group](#output\_security\_group) | Full details about the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the security group |
