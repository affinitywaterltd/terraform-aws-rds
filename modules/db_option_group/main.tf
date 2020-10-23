locals{
  default_oracle_options = {
    STATSPACK = {}
    NATIVE_NETWORK_ENCRYPTION = {
       "SQLNET.CRYPTO_CHECKSUM_SERVER" = "REQUESTED"
       "SQLNET.CRYPTO_CHECKSUM_TYPES_SERVER" = "SHA1,MD5"
       "SQLNET.ENCRYPTION_SERVER" = "REQUESTED"
       "SQLNET.ENCRYPTION_TYPES_SERVER" = "RC4_256,AES256,AES192,3DES168,RC4_128,AES128,3DES112,RC4_56,DES,RC4_40,DES40"
    }
    Timezone = {
      TIME_ZONE = "Europe/London"
    }
    S3_INTEGRATION = {}
    SQLT = {
      LICENSE_PACK = "N"
    }
  }

  default_mssql_options = {}
}

resource "aws_db_option_group" "this" {
  count = var.create ? 1 : 0

  name                     = var.name
  option_group_description = var.option_group_description == "" ? format("Option group for %s", var.identifier) : var.option_group_description
  engine_name              = var.engine_name
  major_engine_version     = var.major_engine_version


  # Oracle
  dynamic "option" {
    for_each = (var.default_options_enabled == true && contains(["oracle-se1", "oracle-se2", "oracle-ee1"],var.engine_name)) ? local.default_oracle_options : {}
    content {
      option_name = option.key

      dynamic "option_settings" {
        for_each = option.value
        content {
          name  = option_settings.key
          value = option_settings.value
        }
      }
      db_security_group_memberships  = []
      vpc_security_group_memberships  = []
      port = 0
    }
  }

  # MSSQL
  dynamic "option" {
    for_each = (var.default_options_enabled == true && var.engine_name == "mssql") ? local.default_mssql_options : {}
    content {
      option_name = option.key

      dynamic "option_settings" {
        for_each = option.value
        content {
          name  = option_settings.key
          value = option_settings.value
        }
        db_security_group_memberships  = []
        vpc_security_group_memberships  = []
        port = 0
      }
    }
  }

  # No Detault Option Supplied
  dynamic "option" {
    for_each =  var.custom_options
    content {
      option_name = option.key

      dynamic "option_settings" {
        for_each = option.value
        content {
          name  = option_settings.key
          value = option_settings.value
        }
        db_security_group_memberships  = []
        vpc_security_group_memberships  = []
        port = 0
      }
    }
  }

/*
  dynamic "option" {
    for_each = (var.default_options == "none" && length(keys(var.options)) != 0) ? var.options : []
    content {
      option_name                    = option.value.option_name
      port                           = lookup(option.value, "port", null)
      version                        = lookup(option.value, "version", null)
      db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
      vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)

      dynamic "option_settings" {
        for_each = lookup(option.value, "option_settings", [])
        content {
          name  = lookup(option_settings.value, "name", null)
          value = lookup(option_settings.value, "value", null)
        }
      }
    }
  }*/

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.identifier)
    },
  )

  timeouts {
    delete = lookup(var.timeouts, "delete", null)
  }

  lifecycle {
    create_before_destroy = true
  }
}