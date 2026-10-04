mock_provider "aws" {
  mock_data "aws_region" {
    defaults = {
      region = "ap-northeast-1"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

run "valid_configuration" {
  command = plan

  variables {
    name_prefix       = "test-prod"
    audit_bucket_name = "test-prod-audit"
  }

  assert {
    condition     = aws_s3_bucket.audit.bucket == "test-prod-audit"
    error_message = "audit bucket 名は変数値そのものであること"
  }

  assert {
    condition     = aws_s3_bucket_versioning.audit.versioning_configuration[0].status == "Enabled"
    error_message = "audit bucket のバージョニングは有効が必須"
  }

  assert {
    condition     = aws_cloudtrail.this.is_multi_region_trail == true
    error_message = "CloudTrail はマルチリージョン証跡が必須"
  }

  assert {
    condition     = aws_guardduty_detector.detector.enable == true
    error_message = "GuardDuty detector は有効が必須"
  }

  assert {
    condition     = aws_kms_key.this.enable_key_rotation == true
    error_message = "KMS CMK の年次ローテーションは有効が必須"
  }
}

run "invalid_name_prefix_rejected" {
  command = plan

  variables {
    name_prefix       = "Invalid_Prefix"
    audit_bucket_name = "test-prod-audit"
  }

  expect_failures = [var.name_prefix]
}

run "invalid_bucket_name_rejected" {
  command = plan

  variables {
    name_prefix       = "test-prod"
    audit_bucket_name = "NG_Name!"
  }

  expect_failures = [var.audit_bucket_name]
}
