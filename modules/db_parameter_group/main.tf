locals {
  description = coalesce(var.description, "Database parameter group for ${var.identifier}")
}

resource "aws_db_parameter_group" "this" {
  count = var.create ? 1 : 0

  name        = var.name
  description = local.description
  family      = var.family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
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