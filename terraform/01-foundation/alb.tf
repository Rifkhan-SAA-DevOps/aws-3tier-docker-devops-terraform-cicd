# -----------------------------
# Public Application Load Balancer
# Internet -> Public ALB -> Frontend ASG
# -----------------------------
resource "aws_lb" "public" {
  name               = "${var.project_name}-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb.id]

  subnets = [
    aws_subnet.public_web_1.id,
    aws_subnet.public_web_2.id
  ]

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-public-alb"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "web"
  }
}

# -----------------------------
# Frontend Target Group
# Public ALB -> Frontend EC2 port 80
# -----------------------------
resource "aws_lb_target_group" "frontend" {
  name     = "${var.project_name}-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project_name}-frontend-tg"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "web"
  }
}

# -----------------------------
# Public HTTP Listener
# Temporary fixed response until frontend ASG exists
# -----------------------------
resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Public ALB is ready. Frontend ASG is not deployed yet."
      status_code  = "200"
    }
  }
}


# -----------------------------
# Internal Backend Application Load Balancer
# Frontend EC2 -> Internal ALB -> Backend ASG
# -----------------------------
resource "aws_lb" "internal" {
  name               = "${var.project_name}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb.id]

  subnets = [
    aws_subnet.private_app_1.id,
    aws_subnet.private_app_2.id
  ]

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-internal-alb"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "app"
  }
}

# -----------------------------
# Backend Target Group
# Internal ALB -> Backend EC2 port 5000
# -----------------------------
resource "aws_lb_target_group" "backend" {
  name     = "${var.project_name}-backend-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/api/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "${var.project_name}-backend-tg"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "app"
  }
}

# -----------------------------
# Internal HTTP Listener
# Temporary fixed response until backend ASG exists
# -----------------------------
resource "aws_lb_listener" "internal_http" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Internal ALB is ready. Backend ASG is not deployed yet."
      status_code  = "200"
    }
  }
}