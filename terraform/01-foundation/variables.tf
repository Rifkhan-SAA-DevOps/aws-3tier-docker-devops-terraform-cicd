variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for AWS resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "db_name" {
  description = "RDS MySQL database name"
  type        = string
}

variable "db_username" {
  description = "RDS MySQL username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS MySQL password"
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "Your public IP for SSH access, example 1.2.3.4/32"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}