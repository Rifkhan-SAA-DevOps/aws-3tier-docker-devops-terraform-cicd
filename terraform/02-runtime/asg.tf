# -----------------------------
# Backend Launch Template
# -----------------------------
resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project_name}-backend-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  key_name      = var.key_name

  iam_instance_profile {
    name = data.terraform_remote_state.foundation.outputs.ec2_instance_profile_name
  }

  vpc_security_group_ids = [
    data.terraform_remote_state.foundation.outputs.backend_ec2_security_group_id
  ]

  user_data = base64encode(templatefile("${path.module}/backend-user-data.sh", {
    aws_region     = var.aws_region
    aws_account_id = data.aws_caller_identity.current.account_id

    backend_image = "${data.terraform_remote_state.foundation.outputs.backend_ecr_repository_url}:latest"

    db_host     = data.terraform_remote_state.foundation.outputs.rds_endpoint
    db_port     = data.terraform_remote_state.foundation.outputs.rds_port
    db_name     = data.terraform_remote_state.foundation.outputs.rds_database_name
    db_user     = var.db_username
    db_password = var.db_password

    jwt_secret = var.jwt_secret
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-backend-instance"
      Project     = var.project_name
      Environment = var.environment
      Tier        = "app"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = "${var.project_name}-backend-volume"
      Project     = var.project_name
      Environment = var.environment
      Tier        = "app"
    }
  }
}

# -----------------------------
# Backend Auto Scaling Group
# -----------------------------
resource "aws_autoscaling_group" "backend" {
  name = "${var.project_name}-backend-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  vpc_zone_identifier = data.terraform_remote_state.foundation.outputs.private_app_subnet_ids

  target_group_arns = [
    data.terraform_remote_state.foundation.outputs.backend_target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-backend-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "app"
    propagate_at_launch = true
  }
}

# -----------------------------
# Frontend Launch Template
# -----------------------------
resource "aws_launch_template" "frontend" {
  name_prefix   = "${var.project_name}-frontend-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  key_name      = var.key_name

  iam_instance_profile {
    name = data.terraform_remote_state.foundation.outputs.ec2_instance_profile_name
  }

  vpc_security_group_ids = [
    data.terraform_remote_state.foundation.outputs.frontend_ec2_security_group_id
  ]

  user_data = base64encode(templatefile("${path.module}/frontend-user-data.sh", {
    aws_region     = var.aws_region
    aws_account_id = data.aws_caller_identity.current.account_id

    frontend_image   = "${data.terraform_remote_state.foundation.outputs.frontend_ecr_repository_url}:latest"
    internal_alb_dns = data.terraform_remote_state.foundation.outputs.internal_alb_dns_name
  }))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-frontend-instance"
      Project     = var.project_name
      Environment = var.environment
      Tier        = "web"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name        = "${var.project_name}-frontend-volume"
      Project     = var.project_name
      Environment = var.environment
      Tier        = "web"
    }
  }
}

# -----------------------------
# Frontend Auto Scaling Group
# -----------------------------
resource "aws_autoscaling_group" "frontend" {
  name = "${var.project_name}-frontend-asg"

  min_size         = 1
  desired_capacity = 1
  max_size         = 2

  vpc_zone_identifier = data.terraform_remote_state.foundation.outputs.public_web_subnet_ids

  target_group_arns = [
    data.terraform_remote_state.foundation.outputs.frontend_target_group_arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-frontend-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "web"
    propagate_at_launch = true
  }

  depends_on = [
    aws_autoscaling_group.backend
  ]
}

# -----------------------------
# Public Listener Rule
# Public ALB -> Frontend Target Group
# -----------------------------
resource "aws_lb_listener_rule" "public_forward_to_frontend" {
  listener_arn = data.terraform_remote_state.foundation.outputs.public_http_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.foundation.outputs.frontend_target_group_arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# -----------------------------
# Internal Listener Rule
# Internal ALB -> Backend Target Group
# -----------------------------
resource "aws_lb_listener_rule" "internal_forward_to_backend" {
  listener_arn = data.terraform_remote_state.foundation.outputs.internal_http_listener_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = data.terraform_remote_state.foundation.outputs.backend_target_group_arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}