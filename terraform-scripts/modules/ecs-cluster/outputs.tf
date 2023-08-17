output "ecs_service" {
  value       = aws_ecs_service.this[*]
  description = "Full details about ECS Services"
}

output "ecs_task_definition" {
  value       = aws_ecs_task_definition.this[*]
  description = "Full details about ECS Task Definitions"
}

output "ecr_repository" {
  value       = aws_ecr_repository.this[*]
  description = "Full details about ECR Repositories"
}

output "cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.this[*]
  description = "Full details about Cloudwatch Log Groups"
}