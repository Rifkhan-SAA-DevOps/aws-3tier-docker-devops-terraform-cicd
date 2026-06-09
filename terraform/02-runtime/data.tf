data "terraform_remote_state" "foundation" {
  backend = "s3"

  config = {
    bucket         = "rifkhan-terraform-devops-states"
    key            = "blog-devops/prod/01-foundation/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "rifkhan-terraform-devops-locks"
    encrypt        = true
  }
}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}