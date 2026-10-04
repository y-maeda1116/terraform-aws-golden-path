output "kms_key_arn" {
  description = "監査・ログ暗号化に使用する共通 KMS CMK の ARN"
  value       = aws_kms_key.this.arn
}

output "audit_bucket_name" {
  description = "CloudTrail / Config ログ保存用バケット名"
  value       = aws_s3_bucket.audit.id
}

output "audit_bucket_arn" {
  description = "CloudTrail / Config ログ保存用バケットの ARN"
  value       = aws_s3_bucket.audit.arn
}
