data "aws_route53_zone" "rawrify-hosted-zone" {
  name = var.env == "prod" ? "rawrify.com" : "dev.rawrify.com"
  private_zone = false
}

resource "aws_route53_record" "cloudfront-ipv4-record" {
  zone_id = data.aws_route53_zone.rawrify-hosted-zone.zone_id
  name    = var.env == "prod" ? "*.rawrify.com" : "*.dev.rawrify.com"
  type    = "A"

  alias {
    name                   = module.cloudfront-distribution.dns_name
    zone_id                = module.cloudfront-distribution.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront-ipv6-record" {
  zone_id = data.aws_route53_zone.rawrify-hosted-zone.zone_id
  name    = var.env == "prod" ? "*.rawrify.com" : "*.dev.rawrify.com"
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