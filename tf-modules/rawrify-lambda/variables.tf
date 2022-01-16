variable "function_name" {
  type = string
  description = "Name of the Lambda function and associated resources."
}

variable "architecture" {
  type = string
  description = "Architecture to use for the Lambda function- x86_64 or arm64. Defaults to arm64."
  default = "arm64"
}

variable "lambda_layer_arns" {
  type = list(string)
  description = "List of the ARNs of Lambda layers that should be attached to this Lambda function"
  default = [""]
}

variable "enable_basic_execution_role" {
  type = bool
  description = "Whether to attach the AWSLambdaBasicExecutionPolicy to the Lambda's IAM role. Defaults to false."
  default = false
}

variable "input_path" {
  type = string
  description = "Path by which the source file for the Lambda can be retrieved"
}

variable "output_path" {
  type = string
  description = "Path at which the zipped Lambda archive will be stored"
}

variable "environment" {
  type = string
  description = "Name of the environment being deployed into"

  validation {
    condition = can(regex("dev|test|prod", var.environment))
    error_message = "Please use dev, test, or prod for environment name."
  }
}

variable "api_execution_arn" {
  type = string
  description = "The execution ARN of the API Gateway that should invoke this Lambda."
}