resource "aws_apigatewayv2_integration" "rawrify-api-integration" {
  api_id = var.api_id
  integration_type = var.integration_type

  connection_type = var.connection_type
  description = "Route to resource for Rawrify"
  integration_method = var.integration_method
  integration_uri = var.integration_uri
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "rawrify-api-route" {
  count = length(var.route_keys)
  api_id = var.api_id
  route_key = var.route_keys[count.index]
  target = "integrations/${aws_apigatewayv2_integration.rawrify-api-integration.id}"
}