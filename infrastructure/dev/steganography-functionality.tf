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
  etag = data.archive_file.steganography-layer-zip.output_md5
  storage_class = "ONEZONE_IA"
}

resource "aws_lambda_layer_version" "steganography-layer" {
  layer_name = "steganography-layer"
  s3_bucket = aws_s3_bucket.rawrify-code-resources-bucket.id
  s3_key = aws_s3_object.stegano-code-upload.key
  compatible_runtimes = ["python3.8"]
}