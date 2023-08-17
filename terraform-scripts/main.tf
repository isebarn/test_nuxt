data "aws_caller_identity" "this" {}

data "aws_region" "this" {}

locals {
  account_id         = data.aws_caller_identity.this.account_id
  region             = data.aws_region.this.name
  environment        = "production"
  pipeline_s3_bucket = "${var.app_name}-${local.region}-${local.account_id}"
}

############################ VPC #################################

module "vpc" {
  source = "./modules/vpc"

  name               = var.app_name
  vpc_cidr_block     = var.vpc_cidr_block
  create_public_only = true

  tags = {
    "Env" = local.environment
  }
}

###################### SECURITY GROUPS ############################

module "security-group-lb" {
  source = "./modules/security-group"

  name      = "${var.app_name}-LB"
  tcp_ports = var.lb_ports
  vpc_id    = module.vpc.vpc_id

  tags = {
    "Env" = local.environment
  }
}

module "security-group-ecs" {
  source = "./modules/security-group"

  name                                  = "${var.app_name}-ECS"
  tcp_ports                             = var.container_ports
  vpc_id                                = module.vpc.vpc_id
  ingress_tcp_source_security_group_ids = [module.security-group-lb.security_group_id]

  tags = {
    "Env" = local.environment
  }
}

########################### LOAD BALANCER ###########################

module "load-balancing" {
  source = "./modules/load-balancer"

  health_check_paths = ["/"]
  name               = [var.app_name]
  load_balancer_name = "${var.app_name}-LB"
  ports              = var.container_ports
  security_groups    = [module.security-group-lb.security_group_id]
  subnet_ids         = module.vpc.public_subnet_ids
  vpc_id             = module.vpc.vpc_id

  tags = {
    "Env" = local.environment
  }
}

########################### ECS CLUSTER #############################

module "ecs" {
  source = "./modules/ecs-cluster"

  cluster_name      = var.app_name
  create_cluster    = true
  name              = [var.app_name]
  port              = var.container_ports
  security_groups   = [module.security-group-ecs.security_group_id]
  subnet_ids        = module.vpc.public_subnet_ids
  target_group_arns = module.load-balancing.target_group_arn

  tags = {
    "Env" = local.environment
  }

  depends_on = [
    module.load-balancing
  ]
}

####################### CODE PIPELINE #################################

module "pipeline" {
  source = "./modules/code-pipeline"

  name                    = var.app_name
  s3_bucket_name          = local.pipeline_s3_bucket
  repository_id           = var.repository_id
  codestar_connection_arn = var.codestar_connection_arn
  branch_name             = var.branch_name
  cluster_name            = var.app_name
  service_name            = module.ecs.ecs_service[0].name

  env_vars = {
    TASKENV        = var.app_name
    REPOSITORY_URI = module.ecs.ecr_repository[0].repository_url
  }

  tags = {
    "Env" = local.environment
  }
}

############################ OUTPUTS ###################################

output "dns_name" {
  value       = module.load-balancing.dns_name
  description = "Domain name of the Load Balancer"
}