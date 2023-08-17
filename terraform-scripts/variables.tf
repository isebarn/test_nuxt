
variable "access_key" {
  type        = string
  description = "Enter the AWS Access Key ID"
}

variable "secret_key" {
  type        = string
  description = "Enter the AWS Secret Access Key"
}

variable "region" {
  type        = string
  description = "Enter the region for your infrastructure"
}

############################## VPC #####################################

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR range for the VPC"
  default     = "10.10.0.0/16"
}

################################## ECS ##################################

variable "app_name" {
  type        = string
  description = "Name for ecs service, task, target-group, Load balancer"
}

variable "container_ports" {
  type        = list(number)
  description = "List of the container ports"
  default     = [3000]
}

########################## SECURITY GROUPS #############################

variable "lb_ports" {
  type        = list(number)
  description = "List of the ports for load balancer"
  default     = [80]
}

########################## CODE PIPELINE #################################

variable "repository_id" {
  type        = string
  description = "Repository ID of Github"
}

variable "branch_name" {
  type        = string
  description = "Name of the source code branch name"
}

variable "codestar_connection_arn" {
  type        = string
  description = "ARN of the code star connection"
}