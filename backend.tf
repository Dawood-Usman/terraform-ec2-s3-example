terraform {
  backend "s3" {
    bucket         = "codingcops-terraform-state-dev"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}