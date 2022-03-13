######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  The steganography related resources for Rawrify.
*/

######################
# LAMBDA LAYER SETUP #
######################

module "steganography-lambda" {
  source = "../../tf-modules/rawrify-lambda"

  api_execution_arn = module.rawrify-api-gateway.api_execution_arn
  environment = var.env
  function_name = "steganography-functionality"
  input_path = "../../lambda_code/steganography-lambda/main.py"
  output_path = "../../lambda_archives/${var.env}/steganography-functionality.zip"
  enable_basic_execution_role = true
  lambda_layer_arns = [aws_lambda_layer_version.requests-toolbelt-layer.arn, aws_lambda_layer_version.cryptography-layer.arn,
  aws_lambda_layer_version.steganography-layer.arn]
}

module "steganography-integration-get" {
  source = "../../tf-modules/rawrify-api-gateway-integration"

  api_id = module.rawrify-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module.steganography-lambda.invoke_arn
  route_keys = ["POST /steg-embed", "POST /steg-retrieve"]
}

# NOTE: Steganography also ships with Pillow. To avoid double-imports, just use steganography layer when Pillow is needed
# Big reason why I'm doing this is Pillow is freaking huge (relatively speaking)
data "archive_file" "steganography-layer-zip" {
  output_path = "../../lambda_archives/${var.env}/steganography-layer.zip"
  type = "zip"
  source_dir = "../../lambda_code/steganography-layer/"
}

# Need to use S3 bucket for Lambda layer upload because layer code is too big for direct uplaod
resource "aws_s3_bucket" "rawrify-code-resources-bucket" {
  bucket = "rawrify-${var.env}-code-resources"

  tags = {
    Environment = var.env
  }
}

resource "aws_s3_bucket_acl" "rawrify-code-resources-private" {
  bucket = aws_s3_bucket.rawrify-code-resources-bucket.id
  acl = "private"
}

resource "aws_s3_object" "stegano-code-upload" {
  bucket = aws_s3_bucket.rawrify-code-resources-bucket.id
  key = "steganography-layer/"
  source = data.archive_file.steganography-layer-zip.output_path
  source_hash = data.archive_file.steganography-layer-zip.output_base64sha256
  storage_class = "ONEZONE_IA"
}

resource "aws_lambda_layer_version" "steganography-layer" {
  layer_name = "steganography-layer"
  s3_bucket = aws_s3_bucket.rawrify-code-resources-bucket.id
  s3_key = aws_s3_object.stegano-code-upload.key
  compatible_runtimes = ["python3.8"]
}