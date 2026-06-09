output "frontend_asg_name" {
  description = "Frontend Auto Scaling Group name"
  value       = aws_autoscaling_group.frontend.name
}

output "backend_asg_name" {
  description = "Backend Auto Scaling Group name"
  value       = aws_autoscaling_group.backend.name
}

output "frontend_launch_template_id" {
  description = "Frontend launch template ID"
  value       = aws_launch_template.frontend.id
}

output "backend_launch_template_id" {
  description = "Backend launch template ID"
  value       = aws_launch_template.backend.id
}