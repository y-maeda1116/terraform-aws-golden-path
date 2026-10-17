# network module

VPC、public/private サブネット（AZ 冗長）、NAT Gateway、VPC Flow Logs、VPC エンドポイント（S3 Gateway 型 + ECR/Logs/SSM/Secrets Manager Interface 型）をプロビジョニングする。

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| name_prefix | string | yes | リソース名プレフィックス |
| vpc_cidr_block | string | no (10.0.0.0/16) | VPC CIDR |
| az_count | number | no (2) | AZ 数（1〜3） |
| kms_key_arn | string | yes | Flow Logs 暗号化用 CMK ARN |
| flow_log_retention_in_days | number | no (90) | Flow Logs 保持日数 |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id / vpc_cidr_block | VPC 識別子 |
| public_subnet_ids | ALB 配置用サブネット |
| private_subnet_ids | ワークロード配置用サブネット |

## 設計メモ

- AZ は `data "aws_availability_zones"` で動的取得（リージョン透過）
- NAT Gateway は AZ 毎に 1 台（AZ 障害時も private サブネットの外向き通信を維持）
- Flow Logs は常時有効。無効化する変数は意図的に存在しない
