######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  The location-related functionality of Rawrify. Location data is retrieved based on the
  requester's IP address, thanks to CloudFront's IP lookup capabilities.

  Creates the location Lambda as well as the necessary API Gateway integration.
*/

module "location-lambda" {
  source = "../../tf-modules/rawrify-lambda"


  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = var.env
  function_name = "location-functionality"
  input_path = "../../lambda_code/location-lambda/main.py"
  output_path = "../../lambda_archives/${var.env}/location-functionality.zip"
  enable_basic_execution_role = true
}

module "location-integration" {
  source = "../../tf-modules/rawrify-api-gateway-integration"


  api_id = module.rawrify-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module.location-lambda.invoke_arn
  route_keys = ["GET /location"]
}