output "alb_dns_name" {
  description = "アプリケーションのエンドポイント（ALB DNS 名）"
  value       = module.compute.alb_dns_name
}

output "alerts_topic_arn" {
  description = "アラート通知用 SNS トピック ARN"
  value       = module.observability.alerts_topic_arn
}

output "ecr_repository_url" {
  description = "アプリコンテナの push 先 ECR リポジトリ"
  value       = module.storage.ecr_repository_url
}
