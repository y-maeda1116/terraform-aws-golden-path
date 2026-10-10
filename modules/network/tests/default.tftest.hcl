mock_provider "aws" {
  mock_data "aws_availability_zones" {
    defaults = {
      names = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
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
    name_prefix = "test-prod"
    kms_key_arn = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    az_count    = 2
  }

  assert {
    condition     = aws_vpc.this.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR はデフォルト /16 を使用"
  }

  assert {
    condition     = length(aws_subnet.public) == 2 && length(aws_subnet.private) == 2
    error_message = "public / private サブネットは az_count と同数（2AZ = 各2）作成"
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 2
    error_message = "NAT Gateway は AZ 障害耐性のため az_count と同数作成"
  }

  assert {
    condition     = alltrue([for s in aws_subnet.private : s.map_public_ip_on_launch == false])
    error_message = "private サブネットは auto-assign public ip を無効化"
  }

  assert {
    condition     = aws_flow_log.this.traffic_type == "ALL"
    error_message = "Flow Logs は全トラフィックタイプを記録"
  }
}

run "invalid_cidr_rejected" {
  command = plan

  variables {
    name_prefix    = "test-prod"
    kms_key_arn    = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    vpc_cidr_block = "10.0.0.999/16"
  }

  expect_failures = [var.vpc_cidr_block]
}

run "invalid_az_count_rejected" {
  command = plan

  variables {
    name_prefix = "test-prod"
    kms_key_arn = "arn:aws:kms:ap-northeast-1:123456789012:key/abcd1234-5678-90ef-ghij-klmnopqrstuv"
    az_count    = 4
  }

  expect_failures = [var.az_count]
}
