data "aws_route53_zone" "rawrify-hosted-zone" {
  name = var.env == "prod" ? "rawrify.com" : "dev.rawrify.com"
  private_zone = false
}

resource "aws_route53_record" "cloudfront-ipv4-wildcard-record" {
  zone_id = data.aws_route53_zone.rawrify-hosted-zone.zone_id
  name    = var.env == "prod" ? "*.rawrify.com" : "*.dev.rawrify.com"
  type    = "A"

  alias {
    name                   = module.cloudfront-distribution.dns_name
    zone_id                = module.cloudfront-distribution.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront-ipv6-wildcard-record" {
  zone_id = data.aws_route53_zone.rawrify-hosted-zone.zone_id
  name    = var.env == "prod" ? "*.rawrify.com" : "*.dev.rawrify.com"
  type    = "AAAA"

  alias {
    name                   = module.cloudfront-distribution.dns_name
    zone_id                = module.cloudfront-distribution.zone_id
    evaluate_target_health = false
  }
}

# An explicit route for ipv4*.rawrify.com traffic-- ensures client is using IPv4 when querying the ipv4 endpoint
resource "aws_route53_record" "cloudfront-ipv4-record" {
  zone_id = data.aws_route53_zone.rawrify-hosted-zone.zone_id
  name    = var.env == "prod" ? "ipv4.rawrify.com" : "ipv4.dev.rawrify.com"
  type    = "A"

  alias {
    name                   = module.cloudfront-distribution.dns_name
    zone_id                = module.cloudfront-distribution.zone_id
    evaluate_target_health = false
  }
}

# An explicit route for ipv6*.rawrify.com traffic-- ensures client is using IPv6 when querying the ipv6 endpoint
resource "aws_route53_record" "cloudfront-ipv6-record" {
  zone_id = data.aws_route53_zone.rawrify-hosted-zone.zone_id
  name    = var.env == "prod" ? "ipv6.rawrify.com" : "ipv6.dev.rawrify.com"
  type    = "AAAA"

  alias {
    name                   = module.cloudfront-distribution.dns_name
    zone_id                = module.cloudfront-distribution.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "user-agent-record" {
  zone_id = data.aws_route53_zone.rawrify-hosted-zone.zone_id
  name = var.env == "prod" ? "user-agent.rawrify.com" : "user-agent.dev.rawrify.com"
  type = "A"

  alias {
    evaluate_target_health = false
    name = module.rawrify-api-gateway.domain_name
    zone_id = module.rawrify-api-gateway.zone_id
  }
}