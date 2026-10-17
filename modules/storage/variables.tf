variable "name_prefix" {
  description = "全リソース名のプレフィックス。小文字英数字とハイフン、3〜24 文字"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,23}$", var.name_prefix))
    error_message = "name_prefix は小文字英数字とハイフンのみ、3〜24 文字で指定してください。"
  }
}

variable "kms_key_arn" {
  description = "S3 暗号化に使用する KMS CMK の ARN"
  type        = string

  validation {
    condition     = startswith(var.kms_key_arn, "arn:aws:kms:")
    error_message = "kms_key_arn は arn:aws:kms: で始まる KMS キー ARN を指定してください。"
  }
}

variable "app_bucket_name" {
  description = "アプリケーションデータ用 S3 バケット名（グローバル一意）"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{2,62}$", var.app_bucket_name))
    error_message = "app_bucket_name は S3 バケット命名規則（小文字英数字・ハイフン・ドット、3〜63 文字）に従ってください。"
  }
}

variable "noncurrent_version_expiration_days" {
  description = "S3 旧バージョンの失効日数"
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1
    error_message = "noncurrent_version_expiration_days は 1 以上を指定してください。"
  }
}

variable "ecr_image_tag_mutability" {
  description = "ECR イメージタグのミュータビリティ"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.ecr_image_tag_mutability)
    error_message = "ecr_image_tag_mutability は MUTABLE または IMMUTABLE を指定してください。"
  }
}

variable "ecr_scan_on_push" {
  description = "ECR プッシュ時にイメージスキャンを実行するか"
  type        = bool
  default     = true
}
