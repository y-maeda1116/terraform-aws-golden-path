variable "aws_region" {
  description = "デプロイ対象リージョン"
  type        = string
  default     = "ap-northeast-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region は AWS リージョン形式（例: ap-northeast-1）で指定してください。"
  }
}

variable "name_prefix" {
  description = "全リソース名のプレフィックス。小文字英数字とハイフン、3〜24 文字"
  type        = string
  default     = "goldenpath-prod"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,23}$", var.name_prefix))
    error_message = "name_prefix は小文字英数字とハイフンのみ、3〜24 文字で指定してください（ALB 名の 32 文字制約のため）。"
  }
}

variable "audit_bucket_name" {
  description = "CloudTrail / AWS Config ログ保存用 S3 バケット名（グローバル一意である必要がある）"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{2,62}$", var.audit_bucket_name))
    error_message = "audit_bucket_name は S3 バケット命名規則（小文字英数字・ハイフン・ドット、3〜63 文字）に従ってください。"
  }
}

variable "app_bucket_name" {
  description = "アプリケーションデータ用 S3 バケット名（グローバル一意である必要がある）"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{2,62}$", var.app_bucket_name))
    error_message = "app_bucket_name は S3 バケット命名規則（小文字英数字・ハイフン・ドット、3〜63 文字）に従ってください。"
  }
}

variable "acm_certificate_arn" {
  description = "ALB HTTPS リスナーで使用する ACM 証明書の ARN（事前に作成したものを指定）"
  type        = string

  validation {
    condition     = startswith(var.acm_certificate_arn, "arn:aws:acm:")
    error_message = "acm_certificate_arn は arn:aws:acm: で始まる ACM 証明書 ARN を指定してください。"
  }
}

variable "alarm_email" {
  description = "CloudWatch アラーム通知先のメールアドレス"
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alarm_email))
    error_message = "alarm_email は有効なメールアドレス形式で指定してください。"
  }
}
