terraform {
  backend "s3" {
    bucket         = "rifkhan-devops-terraform-states"
    key            = "blog-devops/prod/01-foundation/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "rifkhan-devops-terraform-locks"
    encrypt        = true
  }
}