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

//# Create the CloudFront distribution for our website
//resource "aws_cloudfront_distribution" "website-distribution" {
//  enabled = true
//  price_class = "PriceClass_100"  # North America and Europe only
//  default_root_object = "index.html"
//  aliases = ["www.rawrify.com"]
//
//  default_cache_behavior {
//    allowed_methods = ["GET", "HEAD"]
//    cached_methods = ["GET", "HEAD"]
//    target_origin_id = "${aws_s3_bucket.website-bucket.bucket_domain_name}-${var.aws_account_id}"
//    viewer_protocol_policy = "redirect-to-https"
//    compress = true
//    forwarded_values {
//      query_string = false
//      cookies {
//        forward = "none"
//      }
//    }
//
//    min_ttl = 0
//    default_ttl = 3600
//    max_ttl = 86400
//  }
//
//  # Set our S3 bucket with static website content as the origin
//  origin {
//    domain_name = aws_s3_bucket.website-bucket.bucket_regional_domain_name
//    origin_id = "${aws_s3_bucket.website-bucket.bucket_domain_name}-${var.aws_account_id}"
//    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity#updating-your-bucket-policy
//    s3_origin_config {
//      # Here's where the OAI defined above comes in handy. This locks down access to the S3 bucket to ONLY our CloudFront distribution-- traffic can't circumvent CloudFront to S3 directly
//      origin_access_identity = aws_cloudfront_origin_access_identity.website-distribution-identity.cloudfront_access_identity_path
//    }
//  }
//
//  # Lock down to just US, CA, and GB
//  restrictions {
//    geo_restriction {
//      restriction_type = "whitelist"
//      locations = ["US", "CA", "GB"]
//    }
//  }
//
//  # Certificate setup for HTTPS
//  viewer_certificate {
//    acm_certificate_arn = module.rawrify-ipv6-certificate.certificate_arn  # ACM certificate must be in us-east-1 per Terraform documentation
//    ssl_support_method = "sni-only"
//  }
//
//  tags = {
//    Name = "bitinit-cloudfront-distribution"
//  }
//}

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
  bucket = "rawrify-${data.aws_caller_identity.default-provider-account-id.account_id}-website-content"
  acl = "private"

  tags = {
    Name = "rawrify-website-bucket"
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
  etag = filebase64sha256("../../s3-static-site/${each.value}")

  content_type = "text/html"
}

resource "aws_s3_bucket_policy" "website-bucket-policy-attach" {
  bucket = aws_s3_bucket.website-bucket.id
  policy = data.aws_iam_policy_document.website-bucket-policy.json
}