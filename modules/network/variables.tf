variable "name_prefix" {
  description = "全リソース名のプレフィックス。小文字英数字とハイフン、3〜24 文字"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,23}$", var.name_prefix))
    error_message = "name_prefix は小文字英数字とハイフンのみ、3〜24 文字で指定してください。"
  }
}

variable "vpc_cidr_block" {
  description = "VPC の CIDR ブロック"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr_block, 0))
    error_message = "vpc_cidr_block は有効な CIDR 表記（例: 10.0.0.0/16）で指定してください。"
  }
}

variable "az_count" {
  description = "利用するアベイラビリティゾーン数（サブネット・NAT の冗長度）"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 3
    error_message = "az_count は 1〜3 の範囲で指定してください。"
  }
}

variable "kms_key_arn" {
  description = "Flow Logs ロググループの暗号化に使用する KMS CMK の ARN"
  type        = string

  validation {
    condition     = startswith(var.kms_key_arn, "arn:aws:kms:")
    error_message = "kms_key_arn は arn:aws:kms: で始まる KMS キー ARN を指定してください。"
  }
}

variable "flow_log_retention_in_days" {
  description = "Flow Logs のログ保持日数"
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.flow_log_retention_in_days)
    error_message = "flow_log_retention_in_days は CloudWatch Logs の保持期間の選択肢のいずれかを指定してください。"
  }
}
