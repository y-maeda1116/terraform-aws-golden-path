# ALB ターゲット 5xx — 5 分間の合計が閾値以上で発火
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.name_prefix}-alb-target-5xx"
  alarm_description   = "ALB がターゲットから 5xx を多数受け取っている"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = var.alb_5xx_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ECS タスク停止 — 実行タスク数が desired count を下回る状態が持続したら発火
# treat_missing_data = breaching: メトリクス途絶も全タスク停止の可能性として扱う
resource "aws_cloudwatch_metric_alarm" "ecs_tasks_stopped" {
  alarm_name          = "${var.name_prefix}-ecs-tasks-stopped"
  alarm_description   = "ECS サービスの実行タスク数が desired count を下回っている"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "ServiceRunningTaskCount"
  statistic           = "Average"
  period              = 60
  evaluation_periods  = 3
  threshold           = var.ecs_desired_count
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.name_prefix}-lambda-errors"
  alarm_description   = "Lambda 関数でエラーが発生している"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = var.lambda_function_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

# ECS サービス CPU（Container Insights）— 高負荷の持続で発火
# Average = サービス内タスクの平均 CPU 利用率 (%)。Sum は CPU ユニット合計で
# タスク数依存のためスケールアウトで誤発火する
resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "${var.name_prefix}-ecs-cpu-high"
  alarm_description   = "ECS サービスの平均 CPU 使用率が閾値を超えて持続している"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "CpuUtilized"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = var.ecs_cpu_threshold
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
