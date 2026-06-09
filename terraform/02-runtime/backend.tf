terraform {
  backend "s3" {
    bucket         = "rifkhan-terraform-devops-states"
    key            = "blog-devops/prod/02-runtime/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "rifkhan-terraform-devops-locks"
    encrypt        = true
  }
}
