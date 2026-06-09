# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------
# Public Web Subnets
# Public ALB + Frontend ASG
# -----------------------------
resource "aws_subnet" "public_web_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-web-subnet-1"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "web"
    Type        = "public"
  }
}

resource "aws_subnet" "public_web_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-web-subnet-2"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "web"
    Type        = "public"
  }
}

# -----------------------------
# Private App Subnets
# Internal Backend ALB + Backend ASG
# -----------------------------
resource "aws_subnet" "private_app_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.project_name}-private-app-subnet-1"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "app"
    Type        = "private"
  }
}

resource "aws_subnet" "private_app_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.project_name}-private-app-subnet-2"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "app"
    Type        = "private"
  }
}

# -----------------------------
# Private DB Subnets
# RDS MySQL only
# -----------------------------
resource "aws_subnet" "private_db_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.project_name}-private-db-subnet-1"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "database"
    Type        = "private"
  }
}

resource "aws_subnet" "private_db_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.project_name}-private-db-subnet-2"
    Project     = var.project_name
    Environment = var.environment
    Tier        = "database"
    Type        = "private"
  }
}

# -----------------------------
# Elastic IP for NAT Gateway
# -----------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project_name}-nat-eip"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------
# NAT Gateway
# Cost-aware: one NAT Gateway only
# -----------------------------
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_web_1.id

  tags = {
    Name        = "${var.project_name}-nat-gw"
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

# -----------------------------
# Public Route Table
# Public web subnets use IGW
# -----------------------------
resource "aws_route_table" "public_web" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-public-web-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route" "public_web_internet_access" {
  route_table_id         = aws_route_table.public_web.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_web_1" {
  subnet_id      = aws_subnet.public_web_1.id
  route_table_id = aws_route_table.public_web.id
}

resource "aws_route_table_association" "public_web_2" {
  subnet_id      = aws_subnet.public_web_2.id
  route_table_id = aws_route_table.public_web.id
}

# -----------------------------
# Private App Route Table
# Backend EC2 needs NAT to pull ECR images/install packages
# -----------------------------
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-private-app-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route" "private_app_nat_access" {
  route_table_id         = aws_route_table.private_app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private_app_1" {
  subnet_id      = aws_subnet.private_app_1.id
  route_table_id = aws_route_table.private_app.id
}

resource "aws_route_table_association" "private_app_2" {
  subnet_id      = aws_subnet.private_app_2.id
  route_table_id = aws_route_table.private_app.id
}

# -----------------------------
# Private DB Route Table
# RDS does not need internet route
# -----------------------------
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-private-db-rt"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_route_table_association" "private_db_1" {
  subnet_id      = aws_subnet.private_db_1.id
  route_table_id = aws_route_table.private_db.id
}

resource "aws_route_table_association" "private_db_2" {
  subnet_id      = aws_subnet.private_db_2.id
  route_table_id = aws_route_table.private_db.id
}