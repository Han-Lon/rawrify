######################################################
# Rawrify Infrastructure                             #
# Author: Joseph Morris (https://github.com/Han-Lon) #
# Licensed under the Apache-2.0 license              #
######################################################

/*
  Generate necessary certificates in ACM for ipv4.rawrify.com (for API Gateway) and a wilcard *.rawrify.com (for CloudFront)
*/

module "rawrify-user-agent-certificate" {
  source = "../../tf-modules/rawrify-certificate"

  cert_domain_name = "user-agent.rawrify.com"
  route53_domain_name = "rawrify.com"
}

# Why the extra certificate in us-east-1? Because CloudFront can only use certs in us-east-1
module "rawrify-wildcard-certificate" {
  source = "../../tf-modules/rawrify-certificate"
  providers = {
    aws = aws.aws-us-east-1
  }

  cert_domain_name = "*.rawrify.com"
  route53_domain_name = "rawrify.com"
}