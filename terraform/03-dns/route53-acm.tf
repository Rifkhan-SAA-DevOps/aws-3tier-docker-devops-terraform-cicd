# -----------------------------
# ACM Certificate
# -----------------------------
resource "aws_acm_certificate" "main" {
  domain_name = "${var.subdomain_name}.${var.domain_name}"

  subject_alternative_names = ["${var.subdomain_name}.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = lower("${var.project_name}-${var.environment}-acm")
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------
# ACM DNS Validation Records
# -----------------------------
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  zone_id = data.aws_route53_zone.main.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

# -----------------------------
# ACM Certificate Validation
# -----------------------------
resource "aws_acm_certificate_validation" "main" {
  certificate_arn = aws_acm_certificate.main.arn

  validation_record_fqdns = [
    for record in aws_route53_record.cert_validation :
    record.fqdn
  ]
}

# -----------------------------
# HTTPS Listener
# Public ALB HTTPS 443 -> Frontend Target Group
# -----------------------------
resource "aws_lb_listener" "https" {
  load_balancer_arn = data.terraform_remote_state.foundation.outputs.public_alb_arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn
  #    certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.foundation.outputs.frontend_target_group_arn
  }
}

# -----------------------------
# Update HTTP Listener to Redirect HTTP -> HTTPS
# -----------------------------
resource "aws_lb_listener_rule" "http_redirect_to_https" {
  listener_arn = data.terraform_remote_state.foundation.outputs.public_http_listener_arn
  priority     = 1

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# -----------------------------
# Root Domain A Record
# yourdomain.com -> Public ALB
# -----------------------------
resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.foundation.outputs.public_alb_dns_name
    zone_id                = data.terraform_remote_state.foundation.outputs.public_alb_zone_id
    evaluate_target_health = true
  }
}

# -----------------------------
# WWW Domain A Record
# www.yourdomain.com -> Public ALB
# -----------------------------
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.www_domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.foundation.outputs.public_alb_dns_name
    zone_id                = data.terraform_remote_state.foundation.outputs.public_alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.subdomain_name}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.foundation.outputs.public_alb_dns_name
    zone_id                = data.terraform_remote_state.foundation.outputs.public_alb_zone_id
    evaluate_target_health = true
  }
}