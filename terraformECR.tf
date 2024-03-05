

provider "aws" {
    access_key = "AKIAZ56BVM2TBZEH6CFI"
    secret_key = "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"
    region = "us-west-2"
}






resource "aws_ecr_repository" "foo" {
  name                 = "jave-app-ecr2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
