output "zone_id" {
  value = aws_cloudfront_distribution.rawrify-cloudfront-distribution.hosted_zone_id
}

output "dns_name" {
  value = aws_cloudfront_distribution.rawrify-cloudfront-distribution.domain_name
}