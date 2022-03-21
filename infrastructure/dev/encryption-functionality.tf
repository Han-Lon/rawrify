######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  The basic encryption component of Rawrify. Handles encryption of files or strings given a basic private key.

  Do not use GET requests to work with this-- GET requests pass all parameters in the query string, which means
  they're easily intercepted and interpreted by all intermediary listeners, malicious or not. Only POST
*/

module "encryption-lambda" {
  source = "../../tf-modules/rawrify-lambda"

  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = var.env
  function_name = "encryption-functionality"
  input_path = "../../lambda_code/encryption-lambda/main.py"
  output_path = "../../lambda_archives/${var.env}/encryption-functionality.zip"
  enable_basic_execution_role = true
  lambda_layer_arns = [aws_lambda_layer_version.requests-toolbelt-layer.arn, aws_lambda_layer_version.cryptography-layer.arn]
}

module "encryption-integration-get" {
  source = "../../tf-modules/rawrify-api-gateway-integration"

  api_id = module.rawrify-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module.encryption-lambda.invoke_arn
  route_keys = ["POST /encrypt", "POST /decrypt"]
}

data "archive_file" "cryptography-layer-zip" {
  output_path = "../../lambda_archives/${var.env}/crpytography-layer.zip"
  type = "zip"
  source_dir = "../../lambda_code/cryptography-layer/"
}

resource "aws_lambda_layer_version" "cryptography-layer" {
  layer_name = "cryptography-layer"
  filename = data.archive_file.cryptography-layer-zip.output_path
  compatible_runtimes = ["python3.8"]
  source_code_hash = data.archive_file.cryptography-layer-zip.output_base64sha256
}

module "asymmetric-encryption-lambda" {
  source = "../../tf-modules/rawrify-lambda"

  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = var.env
  function_name = "asymmetric-encryption-functionality"
  input_path = "../../lambda_code/asymmetric-encryption-lambda/main.py"
  output_path = "../../lambda_archives/${var.env}/asymmetric-encryption-functionality.zip"
  enable_basic_execution_role = true
  timeout = 5
  lambda_layer_arns = [aws_lambda_layer_version.requests-toolbelt-layer.arn, aws_lambda_layer_version.cryptography-layer.arn]
}

module "asymmetric-encryption-integration" {
  source = "../../tf-modules/rawrify-api-gateway-integration"

  api_id = module.rawrify-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module.asymmetric-encryption-lambda.invoke_arn
  route_keys = ["POST /asymmetric-encrypt", "POST /asymmetric-decrypt"]
}