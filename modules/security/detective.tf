# 脅威検出 (GuardDuty) とセキュリティ姿勢管理 (Security Hub)。
# 有効化が本テンプレートの規約。無効化する変数は意図的に存在しない。
resource "aws_guardduty_detector" "detector" {
  enable = true

  finding_publishing_frequency = "SIX_HOURS"
}

resource "aws_securityhub_account" "this" {
  # アカウント集約でデフォルト標準 (CIS AWS Foundations Benchmark) が有効化される
  auto_enable_controls = true
}

# AWS Config: リソース設定の記録と準拠ドリフトの検出
resource "aws_config_configuration_recorder" "this" {
  name     = "${var.name_prefix}-recorder"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_iam_role" "config" {
  name               = "${var.name_prefix}-config-recorder"
  assume_role_policy = data.aws_iam_policy_document.config_trust.json
}

data "aws_iam_policy_document" "config_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_delivery_channel" "this" {
  name           = "${var.name_prefix}-delivery"
  s3_bucket_name = aws_s3_bucket.audit.id
  s3_key_prefix  = "config"

  depends_on = [aws_config_configuration_recorder.this]
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.this, aws_iam_role_policy_attachment.config]
}
