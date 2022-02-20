######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

# The S3 bucket that will hold the static site files and necessary CloudFront resources
# Q: Why not just host this on S3 without CloudFront?
# A: Although S3 supports static website hosting, it does not support HTTPS traffic-- best way to do this is to sit a CloudFront distribution in front of it

####################
# CloudFront Setup #
####################

# Create the CloudFront OAI (needed later for locking down access to our S3 bucket)
resource "aws_cloudfront_origin_access_identity" "website-distribution-identity" {
  comment = "For the website distribution"
}

############
# S3 Setup #
############

data "aws_iam_policy_document" "website-bucket-policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website-bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website-distribution-identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.website-bucket.arn]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.website-distribution-identity.iam_arn]
    }
  }
}

# Static website S3 bucket
resource "aws_s3_bucket" "website-bucket" {
  bucket = var.env == "prod" ? "rawrify-${data.aws_caller_identity.default-provider-account-id.account_id}-website-content" : "rawrify-dev-website-bucket"
  acl = "private"

  tags = {
    Name = "rawrify-website-bucket"
    Environment = var.env
  }

  # We don't need to enable static website hosting on the S3 bucket itself since we'll be serving content via CloudFront
}

# Block public access -- we'll be serving website content via CloudFront
resource "aws_s3_bucket_public_access_block" "website-bucket-access" {
  bucket = aws_s3_bucket.website-bucket.id

  block_public_acls = true
  ignore_public_acls = true
  block_public_policy = true
  restrict_public_buckets = true
}

# Upload the index.html file
resource "aws_s3_bucket_object" "webpage-file-upload" {
  for_each = fileset("../../s3-static-site/", "**/*.html")

  bucket = aws_s3_bucket.website-bucket.id
  key = each.value
  source = "../../s3-static-site/${each.value}"
  etag = filemd5("../../s3-static-site/${each.value}")

  content_type = "text/html"
}

# Upload the robots.txt file
resource "aws_s3_bucket_object" "robots-file-upload" {
  bucket = aws_s3_bucket.website-bucket.id
  key = "robots.txt"
  source = var.env == "prod" ? "../../s3-static-site/robots.txt" : "../../s3-static-site/dev/robots.txt"
  etag = var.env == "prod" ? filemd5("../../s3-static-site/robots.txt") : filemd5("../../s3-static-site/dev/robots.txt")

  content_type = "text/html"
}

# Upload the favicon.ico file
resource "aws_s3_bucket_object" "favicon-file-upload" {

  bucket = aws_s3_bucket.website-bucket.id
  key = "favicon.ico"
  source = "../../s3-static-site/favicon.ico"
  etag = filemd5("../../s3-static-site/favicon.ico")
}

resource "aws_s3_bucket_policy" "website-bucket-policy-attach" {
  bucket = aws_s3_bucket.website-bucket.id
  policy = data.aws_iam_policy_document.website-bucket-policy.json
}