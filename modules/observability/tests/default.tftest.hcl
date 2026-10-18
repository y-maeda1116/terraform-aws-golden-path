mock_provider "aws" {}

run "valid_configuration" {
  command = plan

  variables {
    name_prefix          = "test-prod"
    kms_key_arn          = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    alarm_email          = "ops@example.com"
    alb_arn_suffix       = "app/test-prod-alb/1234567890"
    ecs_cluster_name     = "test-prod"
    ecs_service_name     = "test-prod-app"
    ecs_desired_count    = 2
    lambda_function_name = "test-prod-s3-processor"
  }

  assert {
    condition     = aws_sns_topic_subscription.alerts.protocol == "email"
    error_message = "アラート通知は email プロトコル"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.ecs_tasks_stopped.threshold == 2 && aws_cloudwatch_metric_alarm.ecs_tasks_stopped.comparison_operator == "LessThanThreshold"
    error_message = "タスク停止アラームは実行数 < desired count で発火"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.alb_5xx.namespace == "AWS/ApplicationELB"
    error_message = "ALB 5xx アラームが定義されていること"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.lambda_errors.threshold == 0
    error_message = "Lambda エラーアラームは閾値 0（1 件でも発火）"
  }
}

run "invalid_email_rejected" {
  command = plan

  variables {
    name_prefix          = "test-prod"
    kms_key_arn          = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    alarm_email          = "not-an-email"
    alb_arn_suffix       = "app/test-prod-alb/1234567890"
    ecs_cluster_name     = "test-prod"
    ecs_service_name     = "test-prod-app"
    ecs_desired_count    = 2
    lambda_function_name = "test-prod-s3-processor"
  }

  expect_failures = [var.alarm_email]
}
