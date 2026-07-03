resource "aws_acm_certificate" "cert" {
  domain_name       = "*.oddshare.com"
  validation_method = "DNS"
}

data "aws_route53_zone" "zone" {
  name         = "oddshare.com"
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "tooling" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "tooling.oddshare.com"
  type    = "A"

  alias {
    name                   = module.ALB.ext_alb_dns_name
    zone_id                = module.ALB.ext_alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wordpress" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "wordpress.oddshare.com"
  type    = "A"

  alias {
    name                   = module.ALB.ext_alb_dns_name
    zone_id                = module.ALB.ext_alb_zone_id
    evaluate_target_health = true
  }
}

