data "aws_route53_zone" "rawrify-hosted-zone" {
  name = "rawrify.com"
  private_zone = false
}

resource "aws_route53_record" "cloudfront-ipv4-record" {
  zone_id = data.aws_route53_zone.rawrify-hosted-zone.zone_id
  name    = "*.rawrify.com"
  type    = "A"

  alias {
    name                   = module.cloudfront-distribution.dns_name
    zone_id                = module.cloudfront-distribution.zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloudfront-ipv6-record" {
  zone_id = data.aws_route53_zone.rawrify-hosted-zone.zone_id
  name    = "*.rawrify.com"
  type    = "AAAA"

  alias {
    name                   = module.cloudfront-distribution.dns_name
    zone_id                = module.cloudfront-distribution.zone_id
    evaluate_target_health = false
  }
}

# TODO add user-agent record