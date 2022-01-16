resource "aws_apigatewayv2_api" "rawrify-api" {
  name = var.api_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "rawrify-api-default-stage" {
  api_id = aws_apigatewayv2_api.rawrify-api.id
  name = "$default"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = var.burst_limit
    throttling_rate_limit = var.rate_limit
  }
}

resource "aws_apigatewayv2_domain_name" "rawrify-custom-domain" {
  count = var.custom_domain_names != "none" ? length(var.custom_domain_names) : 0
  domain_name = var.custom_domain_names[count.index]
  domain_name_configuration {
    certificate_arn = var.custom_domain_certificate
    endpoint_type = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "rawrify-custom-mapping" {
  count = var.custom_domain_names != "none" ? length(var.custom_domain_names) : 0
  api_id = aws_apigatewayv2_api.rawrify-api.id
  domain_name = aws_apigatewayv2_domain_name.rawrify-custom-domain[count.index].domain_name
  stage = aws_apigatewayv2_stage.rawrify-api-default-stage.id
  api_mapping_key = var.custom_domain_name_mappings[count.index]
}