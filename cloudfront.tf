#################################
#  CLOUDFRONT
################################

locals {
  alb_origin_id = "ALBOriginId"
}

resource "aws_cloudfront_distribution" "cf-tf" {

  origin {
    domain_name = aws_lb.alb-tf.dns_name
    origin_id   = local.alb_origin_id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_ssl_protocols     = ["TLSv1"]
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "match-viewer"
    }
  }

  price_class = "PriceClass_All"
  enabled     = true
  comment     = "Cloudfront Distribution pointing to ALBDNS"
  aliases     = [var.subdomain_name]
  depends_on = [
    aws_autoscaling_group.asg-tf
  ]

  default_cache_behavior {
    target_origin_id       = local.alb_origin_id
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    max_ttl                = 86400
    default_ttl            = 3600
    smooth_streaming       = false
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["Host", "Accept", "Accept-Charset", "Accept-Datetime", "Accept-Encoding", "Accept-Language", "Authorization", "Cloudfront-Forwarded-Proto", "Origin", "Referrer"]
    }
    compress = true
  }

  viewer_certificate {
    acm_certificate_arn            = data.aws_acm_certificate.isssued.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
