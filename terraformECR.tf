








resource "aws_ecr_repository" "foo" {
  name                 = "jave-app-ecr2"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
