# モジュール呼び出し順序 = 依存順序: security → network / storage → compute → observability

module "security" {
  source = "../../modules/security"

  name_prefix       = var.name_prefix
  audit_bucket_name = var.audit_bucket_name
}

module "network" {
  source = "../../modules/network"

  name_prefix = var.name_prefix
  kms_key_arn = module.security.kms_key_arn
}

module "storage" {
  source = "../../modules/storage"

  name_prefix     = var.name_prefix
  kms_key_arn     = module.security.kms_key_arn
  app_bucket_name = var.app_bucket_name
}

module "compute" {
  source = "../../modules/compute"

  name_prefix         = var.name_prefix
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  private_subnet_ids  = module.network.private_subnet_ids
  kms_key_arn         = module.security.kms_key_arn
  app_bucket_arn      = module.storage.app_bucket_arn
  acm_certificate_arn = var.acm_certificate_arn
}

module "observability" {
  source = "../../modules/observability"

  name_prefix          = var.name_prefix
  kms_key_arn          = module.security.kms_key_arn
  alarm_email          = var.alarm_email
  alb_arn_suffix       = module.compute.alb_arn_suffix
  ecs_cluster_name     = module.compute.ecs_cluster_name
  ecs_service_name     = module.compute.ecs_service_name
  lambda_function_name = module.compute.lambda_function_name
}
