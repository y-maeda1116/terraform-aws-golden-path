# Lambda: S3 イベント駆動のメタデータ処理サンプル（inbound/ プレフィックスのみ）
data "archive_file" "s3_processor" {
  type        = "zip"
  source_file = "${path.module}/lambda/s3_processor.py"
  output_path = "${path.module}/lambda/s3_processor.py.zip"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.name_prefix}-s3-processor"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.kms_key_arn
}

resource "aws_lambda_function" "s3_processor" {
  function_name    = "${var.name_prefix}-s3-processor"
  role             = aws_iam_role.lambda.arn
  runtime          = var.lambda_runtime
  handler          = "s3_processor.handler"
  filename         = data.archive_file.s3_processor.output_path
  source_code_hash = data.archive_file.s3_processor.output_base64sha256

  kms_key_arn = var.kms_key_arn

  environment {
    variables = {
      LOG_BUCKET_NAME = var.app_bucket_name
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.app_bucket_arn
}

# S3 バケット通知（バケットは storage モジュールの管轄のため、名前は変数で受け取る）
resource "aws_s3_bucket_notification" "app" {
  bucket = var.app_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "inbound/"
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}
