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
    name_prefix         = "test-prod"
    vpc_id              = "vpc-0123456789abcdef0"
    public_subnet_ids   = ["subnet-aaa", "subnet-bbb"]
    private_subnet_ids  = ["subnet-ccc", "subnet-ddd"]
    kms_key_arn         = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    app_bucket_arn      = "arn:aws:s3:::test-prod-app"
    acm_certificate_arn = "arn:aws:acm:ap-northeast-1:123456789012:certificate/abcd1234-abcd-1234-abcd-1234567890ab"
  }

  assert {
    condition     = aws_ecs_service.app.desired_count == 2
    error_message = "ECS desired_count はデフォルト 2（冗長性）"
  }

  assert {
    condition     = aws_ecs_service.app.launch_type == "FARGATE"
    error_message = "ECS は Fargate 起動タイプ"
  }

  assert {
    condition     = aws_ecs_service.app.network_configuration[0].assign_public_ip == false
    error_message = "ECS タスクは public ip 非割り当て（プライベートサブネット配置）"
  }

  assert {
    condition     = aws_lb_listener.https.port == 443
    error_message = "ALB リスナーは HTTPS 443 のみ"
  }

  assert {
    condition     = aws_lambda_function.s3_processor.runtime == "python3.13"
    error_message = "Lambda ランタイムは python3.13"
  }
}

run "invalid_acm_arn_rejected" {
  command = plan

  variables {
    name_prefix         = "test-prod"
    vpc_id              = "vpc-0123456789abcdef0"
    public_subnet_ids   = ["subnet-aaa", "subnet-bbb"]
    private_subnet_ids  = ["subnet-ccc", "subnet-ddd"]
    kms_key_arn         = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    app_bucket_arn      = "arn:aws:s3:::test-prod-app"
    acm_certificate_arn = "arn:aws:notacm:xxx"
  }

  expect_failures = [var.acm_certificate_arn]
}
