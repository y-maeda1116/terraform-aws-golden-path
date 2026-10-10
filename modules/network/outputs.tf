output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR ブロック"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "パブリックサブネット ID のリスト（ALB 用）"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "プライベートサブネット ID のリスト（ECS / Lambda / エンドポイント用）"
  value       = [for s in aws_subnet.private : s.id]
}
