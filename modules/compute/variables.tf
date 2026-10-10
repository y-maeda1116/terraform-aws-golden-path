variable "name_prefix" {
  description = "全リソース名のプレフィックス。小文字英数字とハイフン、3〜24 文字"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,23}$", var.name_prefix))
    error_message = "name_prefix は小文字英数字とハイフンのみ、3〜24 文字で指定してください。"
  }
}

variable "vpc_id" {
  description = "配置先 VPC ID（module.network.vpc_id）"
  type        = string
}

variable "public_subnet_ids" {
  description = "ALB 配置用パブリックサブネット ID（module.network.public_subnet_ids）"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "public_subnet_ids は ALB の AZ 冗長のため 2 つ以上指定してください。"
  }
}

variable "private_subnet_ids" {
  description = "ECS タスク配置用プライベートサブネット ID（module.network.private_subnet_ids）"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "private_subnet_ids はタスクの AZ 冗長のため 2 つ以上指定してください。"
  }
}

variable "kms_key_arn" {
  description = "ロググループ・Lambda 環境変数の暗号化に使用する KMS CMK の ARN"
  type        = string

  validation {
    condition     = startswith(var.kms_key_arn, "arn:aws:kms:")
    error_message = "kms_key_arn は arn:aws:kms: で始まる KMS キー ARN を指定してください。"
  }
}

variable "app_bucket_arn" {
  description = "Lambda のイベント送信元 S3 バケット ARN（module.storage.app_bucket_arn）"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ALB HTTPS リスナーの ACM 証明書 ARN"
  type        = string

  validation {
    condition     = startswith(var.acm_certificate_arn, "arn:aws:acm:")
    error_message = "acm_certificate_arn は arn:aws:acm: で始まる ACM 証明書 ARN を指定してください。"
  }
}

variable "container_image" {
  description = "ECS タスクで実行するコンテナイメージ。ECR の URL または公開イメージ"
  type        = string
  default     = "public.ecr.aws/docker/library/nginx:1.27-alpine"
}

variable "container_port" {
  description = "コンテナのリッスンポート"
  type        = number
  default     = 80

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port は 1〜65535 の範囲で指定してください。"
  }
}

variable "desired_count" {
  description = "ECS サービスの desired count"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_count >= 1 && var.desired_count <= 10
    error_message = "desired_count は 1〜10 の範囲で指定してください。"
  }
}

variable "task_cpu" {
  description = "タスク CPU ユニット（Fargate のサポート値）"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "タスクメモリ MB（Fargate のサポート値）"
  type        = number
  default     = 512
}

variable "lambda_runtime" {
  description = "Lambda ランタイム"
  type        = string
  default     = "python3.13"

  validation {
    condition     = startswith(var.lambda_runtime, "python3.1")
    error_message = "lambda_runtime は python3.13 以上の Python ランタイムを指定してください。"
  }
}

variable "log_retention_in_days" {
  description = "アプリケーションログの保持日数"
  type        = number
  default     = 90

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_in_days)
    error_message = "log_retention_in_days は CloudWatch Logs の保持期間の選択肢のいずれかを指定してください。"
  }
}
