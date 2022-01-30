variable "env" {
  description = "Environment being deployed into. Should be dev or prod."

  validation {
    condition = can(regex("dev|prod", var.env))
    error_message = "The env variable should be dev or prod."
  }
}

variable "dev_account_id" {
  description = "The AWS account ID of the development account."
}

variable "prod_account_id" {
  description = "The AWS account ID of the production account."
}