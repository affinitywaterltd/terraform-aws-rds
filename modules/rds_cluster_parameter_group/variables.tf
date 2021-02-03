variable "create" {
  description = "Whether to create this resource or not?"
  type        = bool
  default     = true
}

variable "default_parameters_enabled" {
  description = "Whether to add default parameters this resource or not?"
  type        = bool
  default     = true
}

variable "description" {
  description = "The description of the DB parameter group"
  type        = string
  default     = ""
}

variable "name" {
  description = "The name of the DB parameter group"
  type        = string
  default     = ""
}

variable "identifier" {
  description = "The identifier of the resource"
  type        = string
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
}

variable "custom_parameters" {
  description = "A list of DB parameter maps to apply"
  type        = any
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
