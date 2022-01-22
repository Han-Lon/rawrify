module "rawrify-api-gateway" {
  source = "../../tf-modules/rawrify-api-gateway"

  api_name = "rawrify-basic-functionality-prod-api"
  burst_limit = 1000
  rate_limit = 1000
  environment = "prod"
  custom_domain_names = ["ipv4.rawrify.com"]
  custom_domain_certificate = module.rawrify-wildcard-certificate.certificate_arn
  custom_domain_name_mappings = [""]
}

module "cloudfront-distribution" {
  source = "../../tf-modules/rawrify-cloudfront"

  environment = "prod"
  origin_domain_name = trimprefix(trimsuffix(module.rawrify-api-gateway.invoke_url, "/"), "https://")
  alternate_domain_certificate = module.rawrify-ipv6-certificate.certificate_arn
  alternate_domain_name = "*.rawrify.com"
  origins = [
    {
      domain_name : trimprefix(trimsuffix(module.rawrify-api-gateway.invoke_url, "/"), "https://")
      origin_id : "rawrify-api-origin"
      origin_path : null
    },
    {
      domain_name : aws_s3_bucket.website-bucket.bucket_regional_domain_name
      origin_id : "rawrify-s3-origin"
      origin_path : null
      S3_config : aws_cloudfront_origin_access_identity.website-distribution-identity.cloudfront_access_identity_path
    }]

  ordered_caches = [
    {
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/ip"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
    },
    {
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/user-agent"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
    },
    {
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/temperature"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
    },
    {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/base64"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = true
    }]
}