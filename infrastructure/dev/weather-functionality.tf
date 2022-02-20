######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  Functionality for retrieving various weather data for locations.

  Stands up a Lambda function and necessary API Gateway integrations
*/

module "weather-lambda" {
  source = "../../tf-modules/rawrify-lambda"


  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = var.env
  function_name = "weather-functionality"
  input_path = "../../lambda_code/weather-lambda/main.py"
  output_path = "../../lambda_archives/${var.env}/weather-functionality.zip"
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
