module "rawrify-wildcard-certificate" {
  source = "../../tf-modules/rawrify-certificate"

  cert_domain_name = "*.rawrify.com"
  route53_domain_name = "rawrify.com"
}

# Why the extra certificate in us-east-1? Because CloudFront can only use certs in us-east-1
module "rawrify-ipv6-certificate" {
  source = "../../tf-modules/rawrify-certificate"
  providers = {
    aws = aws.aws-us-east-1
  }

  cert_domain_name = "ipv6.rawrify.com"
  route53_domain_name = "rawrify.com"
}