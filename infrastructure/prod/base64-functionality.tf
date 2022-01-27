######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  The base64 functionality component of Rawrify. Handles encoding strings and files to Base64 or decoding Base64
  strings into regular strings.

  Stands up a base64 Lambda function and necessary integrations with API Gateway. Plus, a required Lambda layer
  that contains an external Python library for decoding form responses.
*/

module "base64-lambda" {
  source = "../../tf-modules/rawrify-lambda"


  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = "prod"
  function_name = "base64-functionality"
  input_path = "../../lambda_code/base64-lambda/main.py"
  output_path = "../../lambda_archives/base64-functionality.zip"
  enable_basic_execution_role = true
  lambda_layer_arns = [aws_lambda_layer_version.requests-toolbelt-layer.arn]
}

module "base64-integration-get" {
  source = "../../tf-modules/rawrify-api-gateway-integration"


  api_id = module.rawrify-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module.base64-lambda.invoke_arn
  route_keys = ["GET /base64", "POST /base64"]
}

data "archive_file" "requests-toolbelt-layer-zip" {
  output_path = "../../lambda_archives/requests-toolbelt-layer.zip"
  type = "zip"
  source_dir = "../../lambda_code/requests-toolbelt-layer/"
}

resource "aws_lambda_layer_version" "requests-toolbelt-layer" {
  layer_name = "requests-toolbelt-layer"
  filename = data.archive_file.requests-toolbelt-layer-zip.output_path
  compatible_runtimes = ["python3.8"]
  source_code_hash = data.archive_file.requests-toolbelt-layer-zip.output_base64sha256
}