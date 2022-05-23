######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  Functionality to help with time, like fetching current time in UTC, doing timezone conversions, etc
*/

module "time-helper-lambda" {
  source = "../../tf-modules/rawrify-lambda"


  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = var.env
  function_name = "time-helper-function"
  input_path = "../../lambda_code/time-helper/main.py"
  output_path = "../../lambda_archives/${var.env}/time-helper.zip"
  runtime = "python3.9"  # Use Python 3.9 since it implemented a standard library timezone library (ZoneInfo), avoiding the need for pytz
  enable_basic_execution_role = true
}

module "time-helper-integration" {
  source = "../../tf-modules/rawrify-api-gateway-integration"


  api_id = module.rawrify-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module.time-helper-lambda.invoke_arn
  route_keys = ["GET /utc-time-now", "GET /epoch-now", "GET /get-timezone-time", "GET /compare-timezones"]
}