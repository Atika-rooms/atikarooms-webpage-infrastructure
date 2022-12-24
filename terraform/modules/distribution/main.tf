provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"

  default_tags {
    tags = var.aws_default_tags
  }
}

data "aws_route53_zone" "r53_zone" {
  name         = var.root_domain
  private_zone = false
}

# resource "aws_route53_record" "web_domain" {
#   for_each = toset(var.web_domains)

#   allow_overwrite = true
#   name            = each.key
#   type            = "A"

#   alias {
#     name                   = aws_cloudfront_distribution.cdn.domain_name
#     zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
#     evaluate_target_health = false
#   }

#   zone_id = data.aws_route53_zone.r53_zone.zone_id
# }

resource "aws_acm_certificate" "acm_web_certificate" {
  provider                  = aws.us-east-1
  domain_name               = var.web_domains[0]
  subject_alternative_names = [for n in range(length(var.web_domains) - 1) : var.web_domains[n + 1]]
  validation_method         = "DNS"
}


resource "aws_route53_record" "r53_acm_validation_records" {
  for_each = {
    for dvo in aws_acm_certificate.acm_web_certificate.domain_validation_options : dvo.domain_name => {
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
  zone_id         = data.aws_route53_zone.r53_zone.zone_id
}

resource "aws_acm_certificate_validation" "acm_certificate" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.acm_web_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.r53_acm_validation_records : record.fqdn]
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = var.cdn_origin_access.id

    s3_origin_config {
      origin_access_identity = var.cdn_origin_access.path
    }
  }

  enabled             = true
  default_root_object = "index.html"

  aliases = var.web_domains

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.cdn_origin_access.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    compress               = false
    viewer_protocol_policy = "https-only"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  price_class = "PriceClass_100"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.acm_web_certificate.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  lifecycle {
    create_before_destroy = true
  }

}
