terraform {
  backend "s3" {
    bucket = "user-backend-config-files"
    key    = "jaiditya/terraform.tfstate"
    region = "us-east-1"
  }
}
