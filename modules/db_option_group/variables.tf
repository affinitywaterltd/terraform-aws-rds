variable "create" {
  description = "Whether to create this resource or not?"
  type        = bool
  default     = true
}

variable "default_options_enabled" {
  description = "Whether to use the default options or not"
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the resource"
  type        = string
}

variable "identifier" {
  description = "The identifier of the resource"
  type        = string
}

variable "option_group_description" {
  description = "The description of the option group"
  type        = string
  default     = ""
}

variable "engine_name" {
  description = "Specifies the name of the engine that this option group should be associated with"
  type        = string
}

variable "major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string
}

variable "options" {
  description = "A list of Options to apply"
  type        = any
  default     = [
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

variable "timeouts" {
  description = "Define maximum timeout for deletion of `aws_db_option_group` resource"
  type        = map(string)
  default = {
    delete = "15m"
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}


