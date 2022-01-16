output "api_id" {
  value = aws_apigatewayv2_api.rawrify-api.id
}

output "api_execution_arn" {
  value = aws_apigatewayv2_api.rawrify-api.execution_arn
}

output "invoke_url" {
  value = aws_apigatewayv2_stage.rawrify-api-default-stage.invoke_url
}