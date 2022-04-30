
####################################
# ROUTE 53 HEALTH CHECK
####################################

resource "aws_route53_health_check" "tf-health" {
  type             = "HTTP"
  port             = 80
  fqdn             = aws_cloudfront_distribution.cf-tf.domain_name
  request_interval = 30
  tags = {
    Name = "${var.s3-failover}-healthcheck"
  }
}

###################################
##  ROUTE 53 AND HOSTED ZONE
###################################

resource "aws_route53_record" "primary" {
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = "capstone"
  type            = "A"
  set_identifier  = "primary"
  health_check_id = aws_route53_health_check.tf-health.id
  depends_on = [
    aws_cloudfront_distribution.cf-tf
  ]

  alias {
    name                   = aws_cloudfront_distribution.cf-tf.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }

  failover_routing_policy {
    type = "PRIMARY"
  }
}

resource "aws_route53_record" "secondary" {
  zone_id        = data.aws_route53_zone.zone.zone_id
  name           = "capstone"
  set_identifier = "Secondary"
  type           = "A"
  depends_on = [
    aws_cloudfront_distribution.cf-tf
  ]
  alias {
    name                   = "s3-website-us-east-1.amazonaws.com"
    zone_id                = "Z3AQBSTGFYJSTF"
    evaluate_target_health = true
  }
  failover_routing_policy {
    type = "SECONDARY"
  }
}
