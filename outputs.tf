output "cloudfront_url" {
  value       = "http://${aws_cloudfront_distribution.cf-tf.domain_name}"
  description = "CloudFront URL"
}

output "application_url" {
  value       = "https://${aws_route53_record.primary.name}.${var.domain_name}"
  description = "The URL of the application via Route53"
}

output "alb_dns" {
  value       = "http://${aws_lb.alb-tf.dns_name}"
  description = "The DNS name of the load balancer."
}
