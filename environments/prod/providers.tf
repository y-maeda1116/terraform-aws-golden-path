provider "aws" {
  region = var.aws_region

  # 標準化レイヤ: すべてのリソースに強制注入されるタグ（モジュール利用者は上書きできない）
  default_tags {
    tags = {
      Project     = "terraform-aws-golden-path"
      Environment = "prod"
      ManagedBy   = "terraform"
      Repository  = "y-maeda1116/terraform-aws-golden-path"
    }
  }
}
