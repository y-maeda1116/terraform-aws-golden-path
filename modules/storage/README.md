# storage module

アプリケーションデータ用 S3 バケット（SSE-KMS・バージョニング・公開アクセス禁止・SSL 専用・ライフサイクル）と ECR リポジトリ（IMMUTABLE タグ・push 時スキャン）をプロビジョニングする。

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| name_prefix | string | yes | リソース名プレフィックス |
| kms_key_arn | string | yes | 暗号化用 CMK ARN |
| app_bucket_name | string | yes | アプリ用バケット名（グローバル一意） |
| noncurrent_version_expiration_days | number | no (90) | 旧バージョン失効日数 |
| ecr_image_tag_mutability | string | no (IMMUTABLE) | ECR タグミュータビリティ |
| ecr_scan_on_push | bool | no (true) | push 時スキャン |

## Outputs

| Name | Description |
|------|-------------|
| app_bucket_name / app_bucket_arn | アプリ用バケット |
| ecr_repository_url / ecr_repository_arn | ECR リポジトリ |

## 設計メモ

- 暗号化・公開禁止・バージョニングを無効化する変数は意図的に存在しない
