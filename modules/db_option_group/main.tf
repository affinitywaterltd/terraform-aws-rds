locals{
  default_options = [
    {
      option_name = "STATSPACK"
    },
    {
      option_name = "NATIVE_NETWORK_ENCRYPTION"

      option_settings = [
        {
          name  = "SQLNET.CRYPTO_CHECKSUM_SERVER"
          value = "REQUESTED"
        },
        {
          name  = "SQLNET.CRYPTO_CHECKSUM_TYPES_SERVER"
          value = "SHA1,MD5"
        },
        {
          name  = "SQLNET.ENCRYPTION_SERVER"
          value = "REQUESTED"
        },
         {
          name  = "SQLNET.ENCRYPTION_TYPES_SERVER"
          value = "RC4_256,AES256,AES192,3DES168,RC4_128,AES128,3DES112,RC4_56,DES,RC4_40,DES40"
        }
      ]
    },
    {
      option_name = "Timezone"

      option_settings = [
        {
          name  = "TIME_ZONE"
          value = "Europe/London"
        }
      ]
    },
    {
      option_name = "S3_INTEGRATION"
    },
    {
      option_name = "SQLT"

      option_settings = [
        {
          name  = "LICENSE_PACK"
          value = "N"
        }
      ]
    }
  ]
}


resource "aws_db_option_group" "this" {
  count = var.create ? 1 : 0

  name                     = var.name
  option_group_description = var.option_group_description == "" ? format("Option group for %s", var.identifier) : var.option_group_description
  engine_name              = var.engine_name
  major_engine_version     = var.major_engine_version

  dynamic "option" {
    for_each = var.options
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
  }

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

