resource "aws_ecr_repository" "flask" {
  name                 = "flask-backend-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "flask-backend-repo"
  }
}

resource "aws_ecr_repository" "express" {
  name                 = "express-frontend-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "express-frontend-repo"
  }
}

resource "aws_ecr_lifecycle_policy" "flask" {
  repository = aws_ecr_repository.flask.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "express" {
  repository = aws_ecr_repository.express.name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

output "flask_repo_url" {
  value = aws_ecr_repository.flask.repository_url
}

output "express_repo_url" {
  value = aws_ecr_repository.express.repository_url
}
