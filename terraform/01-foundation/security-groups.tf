# -----------------------------
# Public ALB Security Group
# Internet -> Public ALB
# -----------------------------
resource "aws_security_group" "public_alb" {
  name        = "${var.project_name}-public-alb-sg"
  description = "Allow HTTP and HTTPS from internet to public ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-public-alb-sg"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_alb_http" {
  security_group_id = aws_security_group.public_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "public_alb_https" {
  security_group_id = aws_security_group.public_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "public_alb_all_outbound" {
  security_group_id = aws_security_group.public_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# -----------------------------
# Frontend EC2 Security Group
# Public ALB -> Frontend EC2
# Your IP -> SSH
# -----------------------------
resource "aws_security_group" "frontend_ec2" {
  name        = "${var.project_name}-frontend-ec2-sg"
  description = "Allow traffic from public ALB to frontend EC2 instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-frontend-ec2-sg"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "frontend_ssh_from_my_ip" {
  security_group_id = aws_security_group.frontend_ec2.id

  cidr_ipv4   = var.my_ip
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "frontend_http_from_public_alb" {
  security_group_id = aws_security_group.frontend_ec2.id

  referenced_security_group_id = aws_security_group.public_alb.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "frontend_all_outbound" {
  security_group_id = aws_security_group.frontend_ec2.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# -----------------------------
# Internal Backend ALB Security Group
# Frontend EC2 -> Internal ALB
# -----------------------------
resource "aws_security_group" "internal_alb" {
  name        = "${var.project_name}-internal-alb-sg"
  description = "Allow API traffic from frontend EC2 to internal backend ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-internal-alb-sg"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_http_from_frontend" {
  security_group_id = aws_security_group.internal_alb.id

  referenced_security_group_id = aws_security_group.frontend_ec2.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "internal_alb_all_outbound" {
  security_group_id = aws_security_group.internal_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# -----------------------------
# Backend EC2 Security Group
# Internal ALB -> Backend EC2
# Optional SSH only from frontend EC2
# -----------------------------
resource "aws_security_group" "backend_ec2" {
  name        = "${var.project_name}-backend-ec2-sg"
  description = "Allow backend traffic only from internal ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-backend-ec2-sg"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "backend_http_from_internal_alb" {
  security_group_id = aws_security_group.backend_ec2.id

  referenced_security_group_id = aws_security_group.internal_alb.id
  from_port                    = 5000
  ip_protocol                  = "tcp"
  to_port                      = 5000
}

# Optional: SSH to backend only from frontend EC2/bastion path
# Because backend EC2 is private, direct SSH from your laptop will not work.
resource "aws_vpc_security_group_ingress_rule" "backend_ssh_from_frontend" {
  security_group_id = aws_security_group.backend_ec2.id

  referenced_security_group_id = aws_security_group.frontend_ec2.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "backend_all_outbound" {
  security_group_id = aws_security_group.backend_ec2.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


# -----------------------------
# RDS Security Group
# Backend EC2 -> RDS MySQL
# -----------------------------
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow MySQL only from backend EC2 instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "database"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_mysql_from_backend" {
  security_group_id = aws_security_group.rds.id

  referenced_security_group_id = aws_security_group.backend_ec2.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "rds_all_outbound" {
  security_group_id = aws_security_group.rds.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}