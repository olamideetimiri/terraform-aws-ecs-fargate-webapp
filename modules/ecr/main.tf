############################################
# VARIABLES
############################################

variable "project_name" {}

############################################
# ECR REPOSITORY
############################################

resource "aws_ecr_repository" "this" {
  name = "${var.project_name}-repo"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${var.project_name}-repo"
  }
}

############################################
# OUTPUTS
############################################

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "repository_name" {
  value = aws_ecr_repository.this.name
}