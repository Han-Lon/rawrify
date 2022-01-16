variable "api_name" {
  type = string
  description = "Name to give the API Gateway."
}

variable "environment" {
  type = string
  description = "Name of the environment being deployed into"

  validation {
    condition = can(regex("dev|test|prod", var.environment))
    error_message = "Please use dev, test, or prod for environment name."
  }
}

variable "burst_limit" {
  type = number
  description = "The throttling burst limit for the default route."
}

variable "rate_limit" {
  type = number
  description = "The throttling rate limit for the default route"
}

variable "custom_domain_names" {
  type = list(string)
  description = "Custom domain names for API Gateway. List of strings."
  default = ["none"]
}

variable "custom_domain_name_mappings" {
  type = list(string)
  description = "The routes that each of the above custom_domain_names should point to in API Gateway. List of strings."
  default = ["none"]
}

variable "custom_domain_certificate" {
  type = string
  description = "ARN of the custom certificate to use for the custom domain name"
  default = "none"
}