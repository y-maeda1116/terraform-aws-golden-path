output "app_bucket_name" {
  description = "アプリケーションデータ用バケット名"
  value       = aws_s3_bucket.app.id
}

output "app_bucket_arn" {
  description = "アプリケーションデータ用バケットの ARN"
  value       = aws_s3_bucket.app.arn
}

output "ecr_repository_url" {
  description = "ECR リポジトリ URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ECR リポジトリ ARN"
  value       = aws_ecr_repository.app.arn
}
