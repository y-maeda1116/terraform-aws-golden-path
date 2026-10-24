# 進捗ステータス

最終更新: 2026-10-21

## ゴール

最終レビューで起票した follow-up issues (#3〜#14) を順番に一つずつ対応し、
secure AWS foundation テンプレート (Terraform + GitHub Actions) の完成度を上げる。

- 対応フロー: ブランチ作成 → 実装 → 全ゲート (fmt / tflint / test / trivy / secret-scan) →
  Conventional Commits でコミット → PR → CI 緑確認 → merge → 次の issue へ
- 設計書 (SDD) の 11 タスクは全て完了済み。現在は follow-up issues の消化フェーズ

## 完了済み

| Issue | 内容 | PR |
|-------|------|----|
| #3 | trivy-action の SHA ピン更新 (v0.33.0 → v0.36.0) | #15 |
| #4 | workflow に concurrency 追加 | #16 |
| #5 | apply job を専用ロール (AWS_APPLY_ROLE_ARN) に分離 | #17 |
| #11 | README の AWS_APPLY_ROLE_ARN 表記修正 (#5 と同時対応) | #17 |
| #6 | ECS タスク停止アラーム追加 (spec 5.5 の gap) | #18 |
| #7 | terraform plan 出力を job summary へ投稿 | #19 |
| #8 | storage の PAB assert を 4 フラグ全カバー | #20 |
| #9 | S3 命名 validation 重複への相互参照コメント | #21 |

## 進行中

- **#10**: `terraform providers lock -platform=linux_amd64` で各 lock ファイルに
  linux hash を事前取得（CI runner での init 時の非決定的な lock 書き換えを防止）。
  6 lock ファイルの更新はローカルで完了、コミット待ち

## 残タスク

| Issue | 内容 | 備考 |
|-------|------|------|
| #12 | `.tfvars.example` パターンの検討 | 影響調査前提 (plan workflow が terraform.tfvars をデフォルト読み込みするため) |
| #13 | ALB SG の IPv4-only 設計判断コメント追記 | docs |
| #14 | security-base への ignore-unfixed 改善上流 PR 検討 | **外向き操作のためユーザー同意が必要** |
