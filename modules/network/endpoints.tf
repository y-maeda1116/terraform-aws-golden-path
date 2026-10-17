# Gateway 型 (S3): ルートテーブル経由。NAT を介さず S3 アクセス。
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.this.id
  service_name    = "com.amazonaws.${data.aws_region.current.region}.s3"
  route_table_ids = concat([aws_route_table.public.id], [for rt in aws_route_table.private : rt.id])

  policy = data.aws_iam_policy_document.endpoint_s3.json
}

data "aws_iam_policy_document" "endpoint_s3" {
  statement {
    sid    = "S3EndpointAccess"
    effect = "Allow"

    actions   = ["s3:*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    # aws:SourceVpce にエンドポイント自身の ID を使うと policy <-> endpoint で
    # 依存サイクルになるため、プラン時に確定する aws:SourceVpc で同等の制限をする
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpc"
      values   = [aws_vpc.this.id]
    }
  }
}

# Interface 型 (ECR, CloudWatch Logs, SSM, Secrets Manager): プライベートサブネット配置・private DNS 有効
locals {
  interface_endpoints = [
    "com.amazonaws.${data.aws_region.current.region}.ecr.api",
    "com.amazonaws.${data.aws_region.current.region}.ecr.dkr",
    "com.amazonaws.${data.aws_region.current.region}.logs",
    "com.amazonaws.${data.aws_region.current.region}.ssm",
    "com.amazonaws.${data.aws_region.current.region}.secretsmanager",
  ]
}

data "aws_region" "current" {}

resource "aws_security_group" "endpoint" {
  name        = "${var.name_prefix}-vpce-endpoints"
  description = "VPC interface endpoints (HTTPS from VPC CIDR only)"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # エンドポイント ENI が VPC 内クライアントへ応答するのに十分（SG はステートフル）。
  # 全開放 egress は trivy AWS-0104 (CRITICAL) に抵触するため VPC 内 443 のみに制限
  egress {
    description = "HTTPS to VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }
}

resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.interface_endpoints)

  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.private : s.id]
  security_group_ids  = [aws_security_group.endpoint.id]
  private_dns_enabled = true
}
