# terraform-aws-golden-path 設計書

- 日付: 2026-10-03
- ステータス: 承認済み（ユーザーレビュー待ち）
- パス: Architectural

## 1. 目的と背景

SRE / Platform Engineering としての「コード化（IaC）・標準化のセンス」を示すポートフォリオリポジトリ。AWS + Terraform + GitHub Actions によるセキュア基盤テンプレートとして、以下を証明する。

1. **標準化**: タグ付け・命名・暗号化の規約をモジュールレイヤで強制するガードレール設計
2. **セキュリティ**: AWS セキュリティベストプラクティス（暗号化、least privilege、検出系サービス）
3. **CI/CD**: 認証なしで動く静的検証ゲートと、OIDC による安全な plan 実行

### 対象読者

採用担当者・同僚エンジニア。クローン → PR → CI 緑が AWS アカウントなしで再現できること。

## 2. 承認された決定事項

| 決定 | 内容 |
|---|---|
| CI の深度 | ハイブリッド: PR は認証不要の静的チェック、main push は OIDC で `terraform plan` まで。`apply` は `workflow_dispatch` 手動のみ |
| 構成構造 | ローカルモジュール分割（`modules/` + `environments/prod`） |
| ワークロード | ECS Fargate 主軸 + Lambda 1本（S3 イベント駆動） |
| セキュリティ範囲 | 広め: リソース単位の保護に加え GuardDuty / Security Hub / CloudTrail / AWS Config を含む |
| スキャンツール | tfsec（メンテナンスモード）の代替として **Trivy** の misconfig スキャンを採用 |
| アプローチ | 案C: 自前モジュール + 標準化レイヤ（validation / default_tags / 命名規則の強制） |

## 3. 全体構造

```
terraform-aws-golden-path/
├── modules/                     # 再利用可能なローカルモジュール（各モジュールに README 付き）
│   ├── network/                 # VPC, subnet, NAT, Flow Logs, VPC エンドポイント
│   ├── security/                # KMS, CloudTrail, GuardDuty, Security Hub, Config, IAM
│   ├── storage/                 # S3, ECR
│   ├── compute/                 # ECS Fargate, ALB, Lambda
│   └── observability/           # CloudWatch Logs, alarms, SNS
├── environments/
│   └── prod/                    # ルート: モジュール呼び出し + backend + provider
├── .github/
│   ├── workflows/
│   │   ├── terraform-ci.yml     # PR: fmt / validate / tflint / Trivy
│   │   ├── terraform-plan.yml   # main: OIDC 認証で plan（apply は手動）
│   │   └── reusable-secret-scan.yml  # security-base から配布されたローカルコピー
│   ├── CODEOWNERS
│   └── dependabot.yml
├── .tflint.hcl                  # tflint 設定（aws plugin 有効）
├── trivy.yaml                   # Trivy 設定（terraform misconfig scan）
├── .gitignore                   # .env 系を確実に除外
└── README.md                    # 構成図・クイックスタート・設計判断の根拠
```

## 4. 標準化レイヤ（本リポジトリの肝）

すべてのモジュールが守る規約と、その強制手段:

| 規約 | 強制手段 |
|---|---|
| タグ付け基準（`Project` / `Environment` / `ManagedBy` 等） | provider の `default_tags` + モジュール側の `merge()` で強制注入。呼び出し側は上書き不能 |
| 命名規則 `<project>-<env>-<resource>` | モジュール内 `local.name_prefix` に集約し一貫性を保証 |
| 暗号化デフォルト有効（KMS） | 変数で無効化できない設計（暗号化 ON がデフォルトかつ唯一の経路） |
| 入力値の品質 | `validation` ブロック（CIDR 形式、`environment` は `dev`/`staging`/`prod` のみ許可等） |
| リージョン・AZ の妥当性 | `data "aws_availability_zones"` の動的取得（AZ ハードコード禁止） |

## 5. モジュール設計

### 5.1 network

- VPC（/16）、public / private サブネット × 2AZ
- NAT Gateway、VPC Flow Logs（CloudWatch 出力・暗号化）
- VPC エンドポイント: Gateway 型（S3）+ Interface 型（ECR, CloudWatch Logs, SSM, Secrets Manager）

### 5.2 security

- KMS CMK（年次ローテーション有効）
- CloudTrail（KMS 暗号化・S3 保存）
- GuardDuty / Security Hub / AWS Config 有効化
- IAM: ECS タスクロール・実行ロール、Lambda 実行ロール（least privilege、インラインポリシー最小構成）

### 5.3 storage

- アプリ用 S3: KMS 暗号化、バージョニング、ブロックパブリックアクセス全般、SSL 専用（`aws:SecureTransport` 拒否ポリシー）、ライフサイクルルール
- ログ用 S3: CloudTrail・Flow Logs の保存先（同上の保護。オブジェクトロックは導入しない）
- ECR: プッシュ時イメージスキャン、タグイミュータビリティ

### 5.4 compute

- ECS Fargate: awsvpc モード、プライベートサブネット配置、非特権コンテナ（`readOnlyRootFilesystem`、`cap_drop = ["ALL"]`）
- ALB: HTTPS のみ（ACM ARN は変数受け取り）、ヘルスチェック
- Lambda 1本: S3 イベント駆動（アップロードされたオブジェクトのメタデータ処理サンプル）、環境変数は暗号化

### 5.5 observability

- CloudWatch ロググループ: KMS 暗号化、保持期間明示
- アラーム: ALB 5xx 率、ECS タスク停止、Lambda エラー → SNS トピック

## 6. CI/CD パイプライン

### PR 時 — `terraform-ci.yml`（AWS 認証不要）

1. `terraform fmt -check -recursive`
2. `terraform init -backend=false` + `terraform validate`（ルート + 全モジュール）
3. tflint（aws plugin、`.tflint.hcl` 設定）
4. Trivy（`trivy config --scanners misconfig`、`trivy.yaml` 設定）
5. secret-scan（security-base 配布の reusable workflow ローカルコピーを呼び出し）

### main push 時 — `terraform-plan.yml`（GitHub OIDC）

1. OIDC で AWS ロールを引き受ける（静的キーなし、ロール ARN は GitHub Variables / 手順書で指定）
2. `terraform plan` 実行、結果を Actions summary に投稿
3. `apply` は `workflow_dispatch` の手動実行のみ

### 必須ルール（security-base 準拠）

- `uses:` はすべてコミット SHA ピン留め（タグ `@v4` 禁止）
- Dependabot（`github-actions` ecosystem）週次で SHA 更新
- Terraform / tflint / Trivy はバージョン明示指定

## 7. セキュリティ基盤適用と検証戦略

- GitHub リポジトリ作成後、`apply-security.sh` でブランチ保護（rulesets）・Dependabot alerts・シークレットスキャン+プッシュ保護を有効化
- 検証ゲートは CI の静的チェック（fmt / validate / tflint / Trivy / secret-scan）。AWS 未接続でも全検証が通る設計
- README: 構成図（mermaid）、クイックスタート（クローン → bootstrap → plan）、設計判断の根拠
- CODEOWNERS で `.github/` と `modules/` のレビューを強制

## 8. スコープ外（YAGNI）

- RDS / Aurora、Route53 / ACM 証明書の発行（ACM ARN は変数で受け取るのみ）
- マルチ環境ディレクトリ（dev/staging の追加は `environments/` 配下の追加で拡張可能な構造のみ用意）
- Terraform Cloud /Atlantis
- ステートバックエンド（S3 + DynamoDB）の Terraform コード化 — 鶏と卵問題のため README に bootstrap 手順（aws CLI または bootstrap ディレクトリ例）として文書化
- アプリケーションコード（コンテナイメージはサンプルの nginx 等を想定）

## 9. ブランチ・運用

- Conventional Commits（feat / fix / refactor / test / docs / chore / ci）
- 実装は feature ブランチで行い、CI 緑を確認して main へ PR
