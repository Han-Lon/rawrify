module "rawrify-basic-api-gateway" {
  source = "../../tf-modules/rawrify-api-gateway"

  api_name = "rawrify-basic-functionality-prod-api"
  burst_limit = 1000
  rate_limit = 1000
  environment = "prod"
  custom_domain_names = ["ipv4.rawrify.com"]
  custom_domain_certificate = module.rawrify-wildcard-certificate.certificate_arn
  custom_domain_name_mappings = [""]
}

module "_3z-lambda" {
  source = "../../tf-modules/rawrify-lambda"


  api_execution_arn = module.rawrify-basic-api-gateway.api_execution_arn
  environment = "dev"  # TODO change this to prod
  function_name = "3z-functionality"
  input_path = "../../lambda_code/3z-lambda/main.py"
  output_path = "../../lambda_archives/3z-functionality.zip"
  enable_basic_execution_role = true
}

module "_3z-integration" {
  source = "../../tf-modules/rawrify-api-gateway-integration"


  api_id = module.rawrify-basic-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module._3z-lambda.invoke_arn
  route_keys = ["GET /"]
}

module "_3z-ipv6-cloudfront-distribution" {
  source = "../../tf-modules/rawrify-cloudfront"

  environment = "prod"
  origin_domain_name = trimprefix(trimsuffix(module.rawrify-basic-api-gateway.invoke_url, "/"), "https://")
  alternate_domain_certificate = module.rawrify-ipv6-certificate.certificate_arn
  alternate_domain_name = "ipv6.rawrify.com"
}

module "_3z-useragent-integration" {
  source = "../../tf-modules/rawrify-api-gateway-integration"


  api_id = module.rawrify-basic-api-gateway.api_id
  integration_method = "POST"
  integration_uri = module._3z-lambda.invoke_arn
  route_keys = ["GET /user-agent"]
}