## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./modules/ecs-cluster | n/a |
| <a name="module_load-balancing"></a> [load-balancing](#module\_load-balancing) | ./modules/load-balancer | n/a |
| <a name="module_pipeline"></a> [pipeline](#module\_pipeline) | ./modules/code-pipeline | n/a |
| <a name="module_security-group-ecs"></a> [security-group-ecs](#module\_security-group-ecs) | ./modules/security-group | n/a |
| <a name="module_security-group-lb"></a> [security-group-lb](#module\_security-group-lb) | ./modules/security-group | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ./modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_key"></a> [access\_key](#input\_access\_key) | Enter the AWS Access Key ID | `string` | n/a | yes |
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Name for ecs service, task, target-group, Load balancer | `string` | n/a | yes |
| <a name="input_branch_name"></a> [branch\_name](#input\_branch\_name) | Name of the source code branch name | `string` | n/a | yes |
| <a name="input_codestar_connection_arn"></a> [codestar\_connection\_arn](#input\_codestar\_connection\_arn) | ARN of the code star connection | `string` | n/a | yes |
| <a name="input_container_ports"></a> [container\_ports](#input\_container\_ports) | List of the container ports | `list(number)` | <pre>[<br>  3000<br>]</pre> | no |
| <a name="input_lb_ports"></a> [lb\_ports](#input\_lb\_ports) | List of the ports for load balancer | `list(number)` | <pre>[<br>  80<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | Enter the region for your infrastructure | `string` | n/a | yes |
| <a name="input_repository_id"></a> [repository\_id](#input\_repository\_id) | Repository ID of Github | `string` | n/a | yes |
| <a name="input_secret_key"></a> [secret\_key](#input\_secret\_key) | Enter the AWS Secret Access Key | `string` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | CIDR range for the VPC | `string` | `"10.10.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | Domain name of the Load Balancer |
