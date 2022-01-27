######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  The "3z" functions, a double entendre because there's 3 functions (/ipv4, /ipv6, /user-agent) and they're the
  easiest out of everything else to create. Note that by 3 functions, I mean pieces of functionality-- there's just
  one Lambda function.

  Creates the 3z Lambda as well as the IP address and user-agent API Gateway integrations.
*/

module "_3z-lambda" {
  source = "../../tf-modules/rawrify-lambda"


  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = "prod"
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