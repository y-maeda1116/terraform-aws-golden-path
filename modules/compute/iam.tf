# ---- ECS: タスク実行ロール（イメージ取得・ログ書き込みのみ）----
resource "aws_iam_role" "ecs_execution" {
  name               = "${var.name_prefix}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
}

data "aws_iam_policy_document" "ecs_tasks_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---- ECS: タスクロール（アプリから S3 への最小権限）----
resource "aws_iam_role" "ecs_task" {
  name               = "${var.name_prefix}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_trust.json
}

resource "aws_iam_role_policy" "ecs_task_s3" {
  name = "${var.name_prefix}-ecs-task-s3"
  role = aws_iam_role.ecs_task.id

  policy = data.aws_iam_policy_document.ecs_task_s3.json
}

data "aws_iam_policy_document" "ecs_task_s3" {
  statement {
    sid       = "ReadWriteAppBucketObjects"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.app_bucket_arn}/*"]
  }

  statement {
    sid       = "ListAppBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.app_bucket_arn]
  }
}

# ---- Lambda: 実行ロール（ログ書き込み + 送信元バケット読み取りのみ）----
resource "aws_iam_role" "lambda" {
  name               = "${var.name_prefix}-lambda-s3-processor"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

data "aws_iam_policy_document" "lambda_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    # confused-deputy 対策: 自アカウント以外からのロール利用を拒否
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role_policy" "lambda_logs" {
  name = "${var.name_prefix}-lambda-logs"
  role = aws_iam_role.lambda.id

  policy = data.aws_iam_policy_document.lambda_logs.json
}

data "aws_iam_policy_document" "lambda_logs" {
  statement {
    sid    = "WriteFunctionLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.name_prefix}-s3-processor:*"]
  }
}

resource "aws_iam_role_policy" "lambda_s3_read" {
  name = "${var.name_prefix}-lambda-s3-read"
  role = aws_iam_role.lambda.id

  policy = data.aws_iam_policy_document.lambda_s3_read.json
}

data "aws_iam_policy_document" "lambda_s3_read" {
  statement {
    sid       = "ReadAppBucketInbound"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.app_bucket_arn}/inbound/*"]
  }
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}
