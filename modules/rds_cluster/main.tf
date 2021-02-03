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


/*
resource "aws_rds_cluster_instance" "this" {
  count              = 2


  identifier         = "aurora-cluster-demo-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = "db.r4.large"
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
}*/