module "_3z-lambda" {
  source = "../../tf-modules/rawrify-lambda"


  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = "dev"  # TODO change this to prod
  function_name = "3z-functionality"
  input_path = "../../lambda_code/3z-lambda/main.py"
  output_path = "../../lambda_archives/3z-functionality.zip"
  enable_basic_execution_role = true
}

module "_3z-ip-integration" {
  source = "../../tf-modules/rawrify-api-gateway-integration"


  api_id = module.rawrify-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module._3z-lambda.invoke_arn
  route_keys = ["GET /ip"]
}

module "_3z-useragent-integration" {
  source = "../../tf-modules/rawrify-api-gateway-integration"


  api_id = module.rawrify-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module._3z-lambda.invoke_arn
  route_keys = ["GET /user-agent"]
}