resource "aws_cloudfront_distribution" "rawrify-cloudfront-distribution" {
  enabled = true
  is_ipv6_enabled = true
  comment = "Rawrify distribution for ${var.environment}"
  default_root_object = ""
  aliases = [var.alternate_domain_name]
  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id = "rawrify-origin"
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    max_ttl = 0
    default_ttl = 0
    compress = true
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  origin {
    domain_name = var.origin_domain_name
    origin_id = "rawrify-origin"
    origin_path = var.origin_path == "" ? null : var.origin_path
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = var.alternate_domain_certificate
    ssl_support_method = "sni-only"
  }

  price_class = "PriceClass_100"

  tags = {
    Environment = var.environment
  }
}