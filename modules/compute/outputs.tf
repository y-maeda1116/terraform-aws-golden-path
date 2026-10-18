output "alb_dns_name" {
  description = "ALB の DNS 名"
  value       = aws_lb.this.dns_name
}

output "alb_arn_suffix" {
  description = "ALB の ARN サフィックス（CloudWatch メトリクス dimension 用）"
  value       = aws_lb.this.arn_suffix
}

output "ecs_cluster_name" {
  description = "ECS クラスター名"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "ECS サービス名"
  value       = aws_ecs_service.app.name
}

output "lambda_function_name" {
  description = "Lambda 関数名"
  value       = aws_lambda_function.s3_processor.function_name
}

output "ecs_desired_count" {
  description = "ECS サービスの desired count（observability のタスク停止アラーム閾値用）"
  value       = var.desired_count
}
