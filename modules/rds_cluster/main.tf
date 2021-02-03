resource "aws_rds_cluster" "this" {
  count = var.create ? 1 : 0
  cluster_identifier = var.identifier

  engine            = var.engine
  engine_mode       = var.engine_mode
  engine_version    = var.engine_version
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_id

  database_name                       = var.name
  master_username                     = var.username
  master_password                     = var.password
  port                                = var.port
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  iam_roles                           = var.iam_roles

  snapshot_identifier = var.snapshot_identifier

  vpc_security_group_ids          = var.vpc_security_group_ids
  db_subnet_group_name            = var.db_subnet_group_name
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name 

  availability_zones = var.availability_zones

  allow_major_version_upgrade = var.allow_major_version_upgrade 
  apply_immediately           = var.apply_immediately
  skip_final_snapshot         = var.skip_final_snapshot
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot

  backtrack_window        = var.backtrack_window
  backup_retention_period = var.backup_retention_period

  preferred_backup_window      = var.backup_window
  preferred_maintenance_window = var.maintenance_window

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection = var.deletion_protection

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.identifier)
    },
  )

  lifecycle {
    ignore_changes = [
      engine_version,
      preferred_maintenance_window
    ]
  }
}



resource "aws_rds_cluster_instance" "this" {
  count              = var.create ? length(var.cluster_instances) : 0
  cluster_identifier = aws_rds_cluster.this[0].id
  identifier         = "${var.identifier}-${count.index}"
  
  engine               = var.engine
  engine_version       = var.engine_version
  publicly_accessible  = var.publicly_accessible
  db_subnet_group_name = var.db_subnet_group_name
  monitoring_role_arn  = var.monitoring_role_arn

  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  apply_immediately           = var.apply_immediately
  
  copy_tags_to_snapshot       = var.copy_tags_to_snapshot

  instance_class       = lookup(element(var.cluster_instances, count.index), "instance_class", local.default_instance_class)
  monitoring_interval  = lookup(element(var.cluster_instances, count.index), "monitoring_interval", local.default_monitoring_interval)
  promotion_tier       = lookup(element(var.cluster_instances, count.index), "promotion_tier", local.default_promotion_tier)
  availability_zone    = lookup(element(var.cluster_instances, count.index), "availability_zone", null)
  performance_insights_enabled = lookup(element(var.cluster_instances, count.index), "performance_insights_enabled", local.default_performance_insights_enabled)

}