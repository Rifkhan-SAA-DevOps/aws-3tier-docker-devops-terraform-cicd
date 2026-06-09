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

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

