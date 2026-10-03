plugin "terraform" {
  enabled = true
}

plugin "aws" {
  enabled     = true
  version     = "0.39.0" # Task 8 Step 2 で最新に更新
  source      = "github.com/terraform-linters/tflint-ruleset-aws"
}

# 標準ルールセット（terraform_naming_convention 緩め: モジュール内 1 単語リソースを許容）
rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "aws_provider_missing_tags" {
  enabled = false # default_tags はルート provider のみで設定する方針のため、モジュール単位では検査しない
}
