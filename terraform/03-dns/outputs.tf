output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN"
  value       = aws_lb_listener.https.arn
}

output "root_domain_url" {
  description = "Root domain HTTPS URL"
  value       = "https://${var.domain_name}"
}

output "www_domain_url" {
  description = "WWW domain HTTPS URL"
  value       = "https://${var.www_domain_name}"
}