mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

run "valid_configuration" {
  command = plan

  variables {
    name_prefix     = "test-prod"
    kms_key_arn     = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    app_bucket_name = "test-prod-app"
  }

  assert {
    condition     = aws_s3_bucket.app.bucket == "test-prod-app"
    error_message = "app bucket 名は変数値そのものであること"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.app.block_public_acls == true && aws_s3_bucket_public_access_block.app.restrict_public_buckets == true
    error_message = "public access block の 4 項目はすべて有効が必須"
  }

  assert {
    condition = alltrue(flatten([
      for r in aws_s3_bucket_server_side_encryption_configuration.app.rule :
      [for e in r.apply_server_side_encryption_by_default : e.sse_algorithm == "aws:kms"]
    ]))
    error_message = "app bucket は SSE-KMS 暗号化が必須"
  }

  assert {
    condition     = aws_ecr_repository.app.image_tag_mutability == "IMMUTABLE"
    error_message = "ECR のタグは IMMUTABLE が必須"
  }

  assert {
    condition     = aws_ecr_repository.app.image_scanning_configuration[0].scan_on_push == true
    error_message = "ECR は push 時スキャンが必須"
  }
}

run "invalid_bucket_name_rejected" {
  command = plan

  variables {
    name_prefix     = "test-prod"
    kms_key_arn     = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    app_bucket_name = "NG"
  }

  expect_failures = [var.app_bucket_name]
}

run "invalid_mutability_rejected" {
  command = plan

  variables {
    name_prefix              = "test-prod"
    kms_key_arn              = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    app_bucket_name          = "test-prod-app"
    ecr_image_tag_mutability = "MUTABLE!"
  }

  expect_failures = [var.ecr_image_tag_mutability]
}
