output "api_id" {
  value = aws_apigatewayv2_api.rawrify-api.id
}

output "api_execution_arn" {
  value = aws_apigatewayv2_api.rawrify-api.execution_arn
}

output "invoke_url" {
  value = aws_apigatewayv2_stage.rawrify-api-default-stage.invoke_url
}

output "domain_name" {
  value = aws_apigatewayv2_domain_name.rawrify-custom-domain[0].domain_name_configuration[0].target_domain_name
}

output "zone_id" {
  value = aws_apigatewayv2_domain_name.rawrify-custom-domain[0].domain_name_configuration[0].hosted_zone_id
}