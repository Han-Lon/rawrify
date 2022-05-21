######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  What I'm calling the "traffic handling"-- the CloudFront distribution and API Gateway infrastructure that will
  handle incoming user requests and route appropriately.

  Stands up a CloudFront distribution that handles traffic for the static site in S3 as well as API Gateway.
  Also stands up the API Gateway and necessary routes for user traffic.
*/

module "rawrify-api-gateway" {
  source = "../../tf-modules/rawrify-api-gateway"

  api_name = "rawrify-basic-functionality-dev-api"
  burst_limit = 1000
  rate_limit = 250
  environment = var.env
  custom_domain_names = var.env == "prod" ? ["user-agent.rawrify.com"] : ["user-agent.dev.rawrify.com"]
  custom_domain_certificate = module.rawrify-user-agent-certificate.certificate_arn
  custom_domain_name_mappings = [""]
}

module "cloudfront-distribution" {
  source = "../../tf-modules/rawrify-cloudfront"

  environment = var.env
  origin_domain_name = trimprefix(trimsuffix(module.rawrify-api-gateway.invoke_url, "/"), "https://")
  alternate_domain_certificate = module.rawrify-wildcard-certificate.certificate_arn
  alternate_domain_name = var.env == "prod" ? "*.rawrify.com" : "*.dev.rawrify.com"
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
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/location"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = true
      headers = ["CloudFront-Viewer-Country", "CloudFront-Viewer-Country-Name",
      "CloudFront-Viewer-Latitude", "CloudFront-Viewer-Longitude",
      "CloudFront-Viewer-City"]
    },
    {
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/temperature"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = true
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/base64"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = true
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/encrypt"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/decrypt"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/asymmetric-encrypt"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/asymmetric-decrypt"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/steg-embed"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/steg-retrieve"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/utc-time-now"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = true
      headers = null
    },
    {
      allowed_methods = ["GET", "HEAD"]
      cached_methods = ["GET", "HEAD"]
      path_pattern = "/epoch-now"
      target_origin_id = "rawrify-api-origin"
      enable_query_string = false
      headers = null
    },
    ]
}