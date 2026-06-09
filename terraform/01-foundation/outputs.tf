# -----------------------------
# Network Outputs
# -----------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_web_subnet_ids" {
  description = "Public web subnet IDs for public ALB and frontend ASG"
  value = [
    aws_subnet.public_web_1.id,
    aws_subnet.public_web_2.id
  ]
}

output "private_app_subnet_ids" {
  description = "Private app subnet IDs for internal ALB and backend ASG"
  value = [
    aws_subnet.private_app_1.id,
    aws_subnet.private_app_2.id
  ]
}

output "private_db_subnet_ids" {
  description = "Private DB subnet IDs for RDS"
  value = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]
}

output "nat_gateway_id" {
  description = "NAT Gateway ID used by private app subnets"
  value       = aws_nat_gateway.main.id
}

# -----------------------------
# Security Group Outputs
# -----------------------------
output "public_alb_security_group_id" {
  description = "Public ALB security group ID"
  value       = aws_security_group.public_alb.id
}

output "frontend_ec2_security_group_id" {
  description = "Frontend EC2 security group ID"
  value       = aws_security_group.frontend_ec2.id
}

output "internal_alb_security_group_id" {
  description = "Internal backend ALB security group ID"
  value       = aws_security_group.internal_alb.id
}

output "backend_ec2_security_group_id" {
  description = "Backend EC2 security group ID"
  value       = aws_security_group.backend_ec2.id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds.id
}

# -----------------------------
# ECR Outputs
# -----------------------------
output "frontend_ecr_repository_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repository_name" {
  description = "Frontend ECR repository name"
  value       = aws_ecr_repository.frontend.name
}

output "backend_ecr_repository_name" {
  description = "Backend ECR repository name"
  value       = aws_ecr_repository.backend.name
}

# -----------------------------
# IAM Outputs
# -----------------------------
output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "ec2_role_name" {
  description = "EC2 IAM role name"
  value       = aws_iam_role.ec2_role.name
}

# -----------------------------
# RDS Outputs
# -----------------------------
output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "RDS MySQL port"
  value       = aws_db_instance.mysql.port
}

output "rds_database_name" {
  description = "RDS MySQL database name"
  value       = aws_db_instance.mysql.db_name
}

# -----------------------------
# Public ALB Outputs
# -----------------------------
output "public_alb_dns_name" {
  description = "Public ALB DNS name"
  value       = aws_lb.public.dns_name
}

output "public_alb_zone_id" {
  description = "Public ALB Route 53 zone ID"
  value       = aws_lb.public.zone_id
}

output "public_alb_arn" {
  description = "Public ALB ARN"
  value       = aws_lb.public.arn
}

output "frontend_target_group_arn" {
  description = "Frontend target group ARN"
  value       = aws_lb_target_group.frontend.arn
}

output "public_http_listener_arn" {
  description = "Public HTTP listener ARN"
  value       = aws_lb_listener.public_http.arn
}

# -----------------------------
# Internal ALB Outputs
# -----------------------------
output "internal_alb_dns_name" {
  description = "Internal backend ALB DNS name"
  value       = aws_lb.internal.dns_name
}

output "internal_alb_zone_id" {
  description = "Internal backend ALB zone ID"
  value       = aws_lb.internal.zone_id
}

output "internal_alb_arn" {
  description = "Internal backend ALB ARN"
  value       = aws_lb.internal.arn
}

output "backend_target_group_arn" {
  description = "Backend target group ARN"
  value       = aws_lb_target_group.backend.arn
}

output "internal_http_listener_arn" {
  description = "Internal HTTP listener ARN"
  value       = aws_lb_listener.internal_http.arn
}