data "aws_region" "current" {}

# 共通 KMS CMK。年次ローテーション有効・削除保護ウィンドウ付き。
# CloudTrail / CloudWatch Logs / SNS / Lambda がこのキーを使用するため、
# サービスプリンシパルへの許可を key policy で付与する。
resource "aws_kms_key" "this" {
  description             = "${var.name_prefix} golden-path CMK (logs, sns, lambda)"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.kms.json
}

data "aws_iam_policy_document" "kms" {
  # アカウント内 IAM ポリシー経由の利用を許可
  statement {
    sid       = "EnableIAMUserPermissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  # CloudTrail 証跡の暗号化
  statement {
    sid       = "AllowCloudTrail"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*", "kms:DescribeKey"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  # AWS Config の監査バケットへの配信 (バケットはこの CMK の SSE-KMS で暗号化される)
  statement {
    sid       = "AllowConfig"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*", "kms:DescribeKey"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }

  # CloudWatch Logs への暗号化 (VPC Flow Logs / ECS / Lambda ログ)
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  # SNS トピックの暗号化
  statement {
    sid       = "AllowSNS"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }

  # Lambda 環境変数の暗号化
  statement {
    sid       = "AllowLambda"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}
