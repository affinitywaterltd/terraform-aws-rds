locals {
  db_subnet_group_name          = var.db_subnet_group_name != "" ? var.db_subnet_group_name : module.db_subnet_group.this_db_subnet_group_id
  enable_create_db_subnet_group = var.db_subnet_group_name == "" ? var.create_db_subnet_group : false

  parameter_group_name    = var.parameter_group_name != "" ? var.parameter_group_name : "${var.engine}-${var.major_engine_version}-rds-parameter-group-${var.identifier}"
  parameter_group_name_id = var.parameter_group_name != "" ? var.parameter_group_name : module.db_parameter_group.this_db_parameter_group_id

  final_snapshot_string         = "${var.identifier}-final"
  final_snapshot_identifier     = var.final_snapshot_identifier != "" ? var.final_snapshot_identifier : local.final_snapshot_string
  enable_create_db_option_group = var.create_db_option_group ? true : var.option_group_name == "" && var.engine != "postgres"

  option_group_name           = var.option_group_name != "" ? var.option_group_name : "${var.engine}-${var.major_engine_version}-rds-option-group-${var.identifier}"
  option_group_id             = var.option_group_name != "" ? var.option_group_name : module.db_option_group.this_db_option_group_id
  max_allocated_storage = var.allocated_storage * 1.5
}

data "aws_kms_alias" "kms_key_rds" {
  name = "alias/aws/rds"
}

data "aws_iam_role" "rds_enhanced_monitoring_role" {
  name = "rds-enhanced-monitoring-role"
}

module "db_subnet_group" {
  source = "./modules/db_subnet_group"

  create      = local.enable_create_db_subnet_group
  identifier  = var.identifier
  name_prefix = "${var.identifier}-"
  subnet_ids  = var.subnet_ids

  tags = var.tags
}

module "db_parameter_group" {
  source = "./modules/db_parameter_group"

  create          = var.create_db_parameter_group
  identifier      = var.identifier
  name            = local.parameter_group_name
  description     = var.parameter_group_description
  family          = "${var.engine}-${var.major_engine_version}"

  parameters = var.parameters

  tags = var.tags
}

module "db_option_group" {
  source = "./modules/db_option_group"

  create                   = local.enable_create_db_option_group
  identifier               = var.identifier
  name                     = local.option_group_name
  option_group_description = var.option_group_description
  engine_name              = var.engine
  major_engine_version     = var.major_engine_version

  options = var.options

  timeouts = var.option_group_timeouts

  tags = var.tags
}

module "db_instance" {
  source = "./modules/db_instance"

  create                = var.create_db_instance
  identifier            = var.identifier
  engine                = var.engine
  engine_version        = var.engine_version
  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = local.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id == null && var.storage_encrypted == true ? data.aws_kms_alias.kms_key_rds.target_key_id : var.kms_key_id
  license_model         = var.license_model

  name                                = var.name
  username                            = var.username
  password                            = var.password
  port                                = var.port
  domain                              = var.domain
  domain_iam_role_name                = var.domain_iam_role_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  replicate_source_db = var.replicate_source_db

  snapshot_identifier = var.snapshot_identifier

  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = local.db_subnet_group_name
  parameter_group_name   = local.parameter_group_name_id
  option_group_name      = local.option_group_id

  availability_zone   = var.availability_zone
  multi_az            = var.multi_az
  iops                = var.iops
  publicly_accessible = var.publicly_accessible

  ca_cert_identifier = var.ca_cert_identifier

  allow_major_version_upgrade = var.allow_major_version_upgrade
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  maintenance_window          = var.maintenance_window
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot
  final_snapshot_identifier   = var.final_snapshot_identifier

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  monitoring_interval     = var.monitoring_interval_override == false && var.environment =="prod" ? 60 : var.monitoring_interval
  monitoring_role_arn     = var.monitoring_role_arn != "" ? data.aws_iam_role.rds_enhanced_monitoring_role.arn : var.monitoring_role_arn

  monitoring_role_name    = var.monitoring_role_name
  create_monitoring_role  = var.create_monitoring_role

  timezone                        = var.timezone
  character_set_name              = var.character_set_name
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  timeouts = var.timeouts

  deletion_protection      = var.deletion_protection
  delete_automated_backups = var.delete_automated_backups

  tags = var.tags
}
