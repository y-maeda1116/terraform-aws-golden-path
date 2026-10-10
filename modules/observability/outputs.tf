output "alerts_topic_arn" {
  description = "アラート通知用 SNS トピックの ARN"
  value       = aws_sns_topic.alerts.arn
}
