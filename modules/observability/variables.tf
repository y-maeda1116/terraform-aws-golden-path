variable "name_prefix" {
  description = "全リソース名のプレフィックス。小文字英数字とハイフン、3〜24 文字"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,23}$", var.name_prefix))
    error_message = "name_prefix は小文字英数字とハイフンのみ、3〜24 文字で指定してください。"
  }
}

variable "kms_key_arn" {
  description = "SNS トピック暗号化に使用する KMS CMK の ARN"
  type        = string

  validation {
    condition     = startswith(var.kms_key_arn, "arn:aws:kms:")
    error_message = "kms_key_arn は arn:aws:kms: で始まる KMS キー ARN を指定してください。"
  }
}

variable "alarm_email" {
  description = "CloudWatch アラームの通知先メールアドレス"
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alarm_email))
    error_message = "alarm_email は有効なメールアドレス形式で指定してください。"
  }
}

variable "alb_arn_suffix" {
  description = "アラーム対象 ALB の ARN サフィックス（module.compute.alb_arn_suffix）"
  type        = string
}

variable "ecs_cluster_name" {
  description = "アラーム対象 ECS クラスター名（module.compute.ecs_cluster_name）"
  type        = string
}

variable "ecs_service_name" {
  description = "アラーム対象 ECS サービス名（module.compute.ecs_service_name）"
  type        = string
}

variable "lambda_function_name" {
  description = "アラーム対象 Lambda 関数名（module.compute.lambda_function_name）"
  type        = string
}

variable "alb_5xx_threshold" {
  description = "ALB ターゲット 5xx 発火閾値（5 分間の合計）"
  type        = number
  default     = 5
}

variable "ecs_cpu_threshold" {
  description = "ECS サービス CPU 発火閾値（%）。Container Insights メトリクス"
  type        = number
  default     = 80
}
