locals {
  description = coalesce(var.description, "Database parameter group for ${var.identifier}")

  default_postgres_parameters = {}
  /*default_postgres_parameters = {
    "sqlnetora.sqlnet.allowed_logon_version_client" = {
      value = "11"
    }
    "sqlnetora.sqlnet.allowed_logon_version_server" = {
      value = "11"
    }
    "audit_trail" = {
      value = "db"
      apply_method = "pending-reboot"
    }
  }*/
}

resource "aws_rds_cluster_parameter_group" "this" {
  count = var.create ? 1 : 0

  name        = replace(var.name, ".", "-")
  description = local.description
  family      = var.family

  dynamic "parameter" {
    for_each = (var.default_parameters_enabled == true && element(split("-", var.family), 1) == "postgresql") ? local.default_postgres_parameters : tomap({})
    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  dynamic "parameter" {
    for_each = var.custom_parameters
    content {
      name         = parameter.key
      value        = parameter.value.value
      apply_method = lookup(parameter.value, "apply_method", null)
    }
  }

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}