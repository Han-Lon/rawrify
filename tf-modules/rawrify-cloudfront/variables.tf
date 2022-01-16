variable "origin_domain_name" {
  type = string
  description = "Domain name of the origin that the Cloudfront distribution will retrieve."
}

variable "environment" {
  type = string
  description = "Name of the environment being deployed into"

  validation {
    condition = can(regex("dev|test|prod", var.environment))
    error_message = "Please use dev, test, or prod for environment name."
  }
}

variable "alternate_domain_name" {
  description = "Alternate (alias) CNAME domain names for the distribution"
  type = string
}

variable "alternate_domain_certificate" {
  description = "Certificate for the alternate domain name/alias"
  type = string
}

variable "origin_path" {
  description = "An additional path to specify for the origin"
  type = string
  default = ""
}