# 値は利用環境に合わせて変更すること。
# バケット名は S3 のグローバル名前空間で一意である必要がある。
name_prefix         = "goldenpath-prod"
audit_bucket_name   = "goldenpath-prod-audit" # 一意になるよう変更（例: <org>-goldenpath-prod-audit）
app_bucket_name     = "goldenpath-prod-app"   # 一意になるよう変更
acm_certificate_arn = "arn:aws:acm:ap-northeast-1:123456789012:certificate/00000000-0000-0000-0000-000000000000"
alarm_email         = "ops@example.com"
