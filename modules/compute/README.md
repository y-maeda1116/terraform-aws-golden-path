# compute module

ECS Fargate サービス（ALB HTTPS / プライベートサブネット / 非特権コンテナ）と S3 イベント駆動 Lambda（python3.13）、対応 IAM ロール（least privilege）をプロビジョニングする。

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| name_prefix | string | yes | リソース名プレフィックス |
| vpc_id / public_subnet_ids / private_subnet_ids | — | yes | module.network の outputs |
| kms_key_arn | string | yes | ログ暗号化用 CMK ARN |
| app_bucket_arn | string | yes | module.storage の output |
| acm_certificate_arn | string | yes | ALB HTTPS 用証明書 |
| container_image | string | no (nginx:1.27-alpine) | コンテナイメージ |
| container_port / desired_count / task_cpu / task_memory | number | no | タスク定義 |
| lambda_runtime | string | no (python3.13) | Lambda ランタイム |
| log_retention_in_days | number | no (90) | ログ保持日数 |

## Outputs

| Name | Description |
|------|-------------|
| alb_dns_name / alb_arn_suffix | ALB 識別子 |
| ecs_cluster_name / ecs_service_name | ECS 識別子 |
| lambda_function_name | Lambda 関数名 |

## 設計メモ

- コンテナは privileged=false / readonlyRootFilesystem / CAP_DROP ALL を強制
- IAM ポリシーは `data "aws_iam_policy_document"` でリソースを明示限定（ワイルドカード禁止）
- Lambda は inbound/ プレフィックスの PUT のみ処理。ロギングはアプリログと同じ CMK で暗号化
