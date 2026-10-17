# ステートバックエンド（bootstrap 手順はリポジトリルート README.md を参照）。
# ロックは DynamoDB ではなく Terraform 1.11+ の S3 native lockfile を使用。
terraform {
  backend "s3" {
    bucket       = "goldenpath-tfstate" # bootstrap 時に作成した一意なバケット名に変更
    key          = "prod/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
    encrypt      = true
  }
}
