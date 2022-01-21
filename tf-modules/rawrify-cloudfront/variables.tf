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

variable "origins" {
  description = "Origins to add to CloudFront."
  type = list(map(string))
}

variable "ordered_caches" {
  description = "Ordered cache behaviors for the CloudFront distribution."
  type = list(object({
    allowed_methods = list(string)
    cached_methods = list(string)
    path_pattern = string
    target_origin_id = string
    enable_query_string = bool
  }))
}