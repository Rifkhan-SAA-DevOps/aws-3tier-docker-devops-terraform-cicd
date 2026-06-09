# -----------------------------
# GitHub Actions OIDC Provider
# -----------------------------
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
  
}

# -----------------------------
# IAM Role for GitHub Actions to Push Images to ECR
# -----------------------------
resource "aws_iam_role" "github_actions_ecr_push" {
  name = "${var.project_name}-github-actions-ecr-push-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner}/${var.github_repo}:ref:refs/heads/${var.github_branch}"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-github-actions-ecr-push-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

# -----------------------------
# Least-Privilege ECR Push Policy
# -----------------------------
resource "aws_iam_policy" "github_actions_ecr_push" {
  name        = "${var.project_name}-github-actions-ecr-push-policy"
  description = "Allow GitHub Actions to push frontend and backend images to ECR"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "GetECRAuthorizationToken"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },
      {
        Sid    = "PushPullFrontendBackendImages"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
          "ecr:BatchGetImage"
        ]

        Resource = [
          aws_ecr_repository.frontend.arn,
          aws_ecr_repository.backend.arn
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-github-actions-ecr-push-policy"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_push" {
  role       = aws_iam_role.github_actions_ecr_push.name
  policy_arn = aws_iam_policy.github_actions_ecr_push.arn
}