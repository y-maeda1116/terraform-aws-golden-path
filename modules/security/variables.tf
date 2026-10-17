variable "name_prefix" {
  description = "全リソース名のプレフィックス。小文字英数字とハイフン、3〜24 文字"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,23}$", var.name_prefix))
    error_message = "name_prefix は小文字英数字とハイフンのみ、3〜24 文字で指定してください。"
  }
}

variable "audit_bucket_name" {
  description = "CloudTrail / AWS Config ログ保存用 S3 バケット名（グローバル一意）"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{2,62}$", var.audit_bucket_name))
    error_message = "audit_bucket_name は S3 バケット命名規則（小文字英数字・ハイフン・ドット、3〜63 文字）に従ってください。"
  }
}

variable "kms_deletion_window_in_days" {
  description = "KMS CMK 削除までの待機日数"
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "kms_deletion_window_in_days は 7〜30 の範囲で指定してください。"
  }
}

# 後続タスクの CloudWatch Logs 連携で使用する
# tflint-ignore: terraform_unused_declarations
variable "log_retention_in_days" {
  description = "CloudTrail イベントのログ保持日数"
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_in_days)
    error_message = "log_retention_in_days は CloudWatch Logs の保持期間の選択肢（1,3,5,7,14,30,60,90,120,...3653）のいずれかを指定してください。"
  }
}
