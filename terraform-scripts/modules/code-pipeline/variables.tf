variable "env_vars" {
  type        = map(string)
  description = "key and value pair of environment variables for code build project"
  default     = null
}

variable "ec2_tag_filters" {
  type        = map(string)
  description = "Key and value pairs of ec2 instance tags for code deployment group"
  default     = null
}

variable "name" {
  type        = string
  description = "Name for this infrastructure"
}

variable "create_s3_bucket" {
  type        = bool
  description = "Whehter the S3 bucket for codepipeline should be create"
  default     = true
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the pipeline s3 bucket."
  default     = null
}

variable "backend_deployment" {
  type        = bool
  description = "For the Backend deployment"
  default     = false
}

variable "ecs_deployment" {
  type        = bool
  description = "For the ECS deployment"
  default     = true
}

variable "ec2_deployment" {
  type        = bool
  description = "For the EC2 deployment"
  default     = false
}

variable "source_provider" {
  type        = string
  description = "Name of the source provider for the code pipeline"
  default     = "CodeStarSourceConnection"
}

variable "source_owner" {
  type        = string
  description = "Owner of the source provider for the code pipeline"
  default     = "AWS"
}

variable "repository_id" {
  type        = string
  description = "ID of the github or any other provider's repository"
  default     = null
}

variable "repository_name" {
  type        = string
  description = "Name of the code commit repository"
  default     = null
}

variable "branch_name" {
  type        = string
  description = "Name of the source code branch name"
  default     = null
}

variable "codestar_connection_arn" {
  type        = string
  description = "ARN of the code star connection"
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "Name of the ECS Cluster name"
  default     = null
}

variable "service_name" {
  type        = string
  description = "Name of the ECS Service name"
  default     = null
}

variable "privileged_mode" {
  type        = bool
  description = "Whether to enable running the Docker daemon inside a Docker container."
  default     = true
}

variable "image_identifier" {
  type        = string
  description = "Docker image to use for this build project."
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
}

variable "tags" {
  type        = map(string)
  description = "Tags for this infrastructure"
  default     = {}
}

variable "create_deploy_group" {
  type        = bool
  description = "Whether the deployment group shoul be create or not"
  default     = true
}

variable "codedeploy_app" {
  type        = string
  description = "Name of the code deployment app. Is needed if 'create_deploy_group' is set to 'false'"
  default     = null
}

variable "deployment_group" {
  type        = string
  description = "Name of the code deployment group. Is needed if 'create_deploy_group' is set to 'false'"
  default     = null
}