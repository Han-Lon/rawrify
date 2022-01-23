resource "aws_cloudfront_distribution" "rawrify-cloudfront-distribution" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Rawrify distribution for ${var.environment}"
  default_root_object = "index.html"
  aliases             = [var.alternate_domain_name]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "rawrify-s3-origin"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    max_ttl                = 0
    default_ttl            = 0
    compress               = true
    forwarded_values {
      query_string = true # TODO make cache behavior a dynamic var so not all query strings are enabled
      cookies {
        forward = "none"
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_caches
    content {
      allowed_methods        = ordered_cache_behavior.value["allowed_methods"]
      cached_methods         = ordered_cache_behavior.value["cached_methods"]
      path_pattern           = ordered_cache_behavior.value["path_pattern"]
      target_origin_id       = ordered_cache_behavior.value["target_origin_id"]
      viewer_protocol_policy = "https-only"
      min_ttl                = 0
      max_ttl                = 0
      default_ttl            = 0
      forwarded_values {
        query_string = ordered_cache_behavior.value["enable_query_string"]
        cookies {
          forward = "none"
        }
      }
    }
  }

  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name = origin.value["domain_name"]
      origin_id   = origin.value["origin_id"]
      origin_path = origin.value["origin_path"]
      dynamic "custom_origin_config" {
        for_each = contains(keys(origin.value), "S3_config") ? [] : [origin.value]
        content {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"
          origin_ssl_protocols   = ["TLSv1.2"]
        }
      }
      dynamic "s3_origin_config" {
        for_each = contains(keys(origin.value), "S3_config") ? [origin.value["S3_config"]] : []
        content {
          # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity#updating-your-bucket-policy
          # Here's where the OAI defined above comes in handy. This locks down access to the S3 bucket to ONLY our CloudFront distribution-- traffic can't circumvent CloudFront to S3 directly
          origin_access_identity = origin.value["S3_config"]
        }
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.alternate_domain_certificate
    ssl_support_method             = "sni-only"
  }

  price_class = "PriceClass_100"

  tags = {
    Environment = var.environment
  }
}