resource "aws_acm_certificate" "rawrify-cert" {
  domain_name = var.cert_domain_name
  validation_method = "DNS"
}

data "aws_route53_zone" "rawrify-domain" {
  name = var.route53_domain_name
  private_zone = false
}

resource "aws_route53_record" "rawrify-cert-records" {
  for_each = {
    for dvo in aws_acm_certificate.rawrify-cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.rawrify-domain.zone_id
}

resource "aws_acm_certificate_validation" "rawrify-cert-validation" {
  certificate_arn = aws_acm_certificate.rawrify-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.rawrify-cert-records : record.fqdn]
}