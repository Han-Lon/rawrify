variable "cert_domain_name" {
  type = string
  description = "Domain name to assign to the certificate."
}

variable "route53_domain_name" {
  type = string
  description = "Route53 Hosted Zone domain name to be used for certificate validation"
}