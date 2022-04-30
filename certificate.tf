
##################################
# CERTIFICATE MANAGER 
##################################

# Find a certificate that is isssued

data "aws_acm_certificate" "isssued" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

# To use exist hosted zone 

data "aws_route53_zone" "zone" {
  name         = var.domain_name
  private_zone = false
}

#------------------------------------------------------------------------------
# If you want to create new cert and create cname record to your hosted zone,
# You can use this code bloks, I prefer using my existing ACM Cert
#------------------------------------------------------------------------------- 

# resource "aws_acm_certificate" "cert" {
#   domain_name       = var.subdomain_name
#   validation_method = "DNS"
#   tags = {
#     "Name" = var.subdomain_name
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "cert_validation" {
#   depends_on      = [aws_acm_certificate.cert]
#   zone_id         = data.aws_route53_zone.zone.id
#   name            = sort(aws_acm_certificate.cert.domain_validation_options[*].resource_record_name)[0]
#   type            = "CNAME"
#   ttl             = "300"
#   records         = [sort(aws_acm_certificate.cert.domain_validation_options[*].resource_record_value)[0]]
#   allow_overwrite = true

# }

# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [
#     aws_route53_record.cert_validation.fqdn
#   ]
#   timeouts {
#     create = "60m"
#   }
# }
