module "weather-lambda" {
  source = "../../tf-modules/rawrify-lambda"


  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = "dev"  # TODO change this to prod
  function_name = "weather-functionality"
  input_path = "../../lambda_code/weather-lambda/main.py"
  output_path = "../../lambda_archives/weather-functionality.zip"
  enable_basic_execution_role = true
  lambda_layer_arns = [aws_lambda_layer_version.requests-toolbelt-layer.arn]
}

module "weather-integration-get" {
  source = "../../tf-modules/rawrify-api-gateway-integration"


  api_id = module.rawrify-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module.weather-lambda.invoke_arn
  route_keys = ["GET /temperature"]
}
