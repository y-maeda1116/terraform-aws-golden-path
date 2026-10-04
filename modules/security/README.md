# security module

KMS CMK・監査用 S3 バケット・CloudTrail・GuardDuty・Security Hub・AWS Config をプロビジョニングする。

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| name_prefix | string | yes | リソース名プレフィックス（3〜24 文字） |
| audit_bucket_name | string | yes | 監査ログ用 S3 バケット名（グローバル一意） |
| kms_deletion_window_in_days | number | no (30) | KMS CMK 削除待機日数（7〜30） |
| log_retention_in_days | number | no (90) | ログ保持日数 |

## Outputs

| Name | Description |
|------|-------------|
| kms_key_arn | 共通 KMS CMK の ARN |
| audit_bucket_name | 監査バケット名 |
| audit_bucket_arn | 監査バケット ARN |

## 設計メモ

- 暗号化・検出系の無効化する変数は意図的に存在しない（標準化レイヤによる強制）
- 監査バケットは本モジュール内で作成し、CloudTrail との循環依存を断っている
