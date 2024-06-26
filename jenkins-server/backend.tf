terraform {
  backend "s3" {
    bucket = "man-terraform-state-bucket"
    key = "jenkins/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "jenkins-terraform-lock"
    encrypt = true
  }
}

