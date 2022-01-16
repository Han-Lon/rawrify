variable "api_id" {
  type = string
  description = "The API ID of the AWS API Gateway to integrate with"
}

variable "integration_type" {
  type = string
  description = "Type of API Gateway integration. Defaults to AWS_PROXY"
  default = "AWS_PROXY"
}

variable "connection_type" {
  type = string
  description = "Type of connection for the API Gateway integration. Defaults to INTERNET"
  default = "INTERNET"
}

variable "integration_method" {
  type = string
  description = "HTTP method by which the integration will serve traffic."
}

variable "integration_uri" {
  type = string
  description = "The URI of the resource to be invoked by the integration. Use invoke_arn for Lambdas."
}

variable "route_keys" {
  type = list(string)
  description = "The route keys for the integration's route in API Gateway. The 'path', so to speak. Multiple routes can share the same integration, hence the list(string) type."
}