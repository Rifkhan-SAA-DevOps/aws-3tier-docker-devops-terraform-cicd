variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Root domain name"
  type        = string
}

variable "www_domain_name" {
  description = "WWW domain name"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name"
  type        = string
}

# variable "certificate_arn" {
#   description = "Existing ACM certificate ARN in the same region as the public ALB"
#   type        = string
# }