# observability module

アラート通知用 SNS トピック（CMK 暗号化）と CloudWatch メトリクスアラーム（ALB 5xx / Lambda エラー / ECS CPU）をプロビジョニングする。

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| name_prefix | string | yes | リソース名プレフィックス |
| kms_key_arn | string | yes | SNS 暗号化用 CMK ARN |
| alarm_email | string | yes | 通知先メールアドレス |
| alb_arn_suffix / ecs_cluster_name / ecs_service_name / lambda_function_name | string | yes | アラーム対象（module.compute の outputs） |
| ecs_desired_count | number | yes | タスク停止アラーム閾値（module.compute.ecs_desired_count） |
| alb_5xx_threshold | number | no (5) | 5xx 発火閾値 |
| ecs_cpu_threshold | number | no (80) | CPU 発火閾値（%） |

## Outputs

| Name | Description |
|------|-------------|
| alerts_topic_arn | SNS アラートトピック ARN |

## 設計メモ

- アラーム対象は compute モジュールの outputs（文字列）で受け取り、リソース依存を作らない
- 通知先は email サブスクリプション（ChatBot / Slack は利用者が追加）
