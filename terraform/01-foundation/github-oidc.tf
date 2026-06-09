data "aws_caller_identity" "current" {}
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


# -----------------------------
# IAM Policy for GitHub Actions to run DB migration via SSM
# -----------------------------
resource "aws_iam_policy" "github_actions_ssm_migration" {
  name        = "${var.project_name}-github-actions-ssm-migration-policy"
  description = "Allow GitHub Actions to run database migration commands on backend EC2 instances through SSM"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowSendCommandToBackendInstances"
        Effect = "Allow"

        Action = [
          "ssm:SendCommand"
        ]

        Resource = [
          "arn:aws:ssm:${var.aws_region}:*:document/AWS-RunShellScript",
          "arn:aws:ec2:${var.aws_region}:*:instance/*"
        ]

        Condition = {
          StringEquals = {
            "ssm:resourceTag/Tier" = "app"
          }
        }
      },
      {
        Sid    = "AllowReadCommandInvocation"
        Effect = "Allow"

        Action = [
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands"
        ]

        Resource = "*"
        }, {
        Sid    = "AllowDescribeEC2Instances"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowSSMSendCommand"
        Effect = "Allow"
        Action = [
          "ssm:SendCommand"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript",
          "arn:aws:ec2:${var.aws_region}:${data.aws_caller_identity.current.account_id}:instance/*"
        ]
      },
      {
        Sid    = "AllowSSMCommandStatus"
        Effect = "Allow"
        Action = [
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:ListCommands"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-github-actions-ssm-migration-policy"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_ssm_migration" {
  role       = aws_iam_role.github_actions_ecr_push.name
  policy_arn = aws_iam_policy.github_actions_ssm_migration.arn
}


resource "aws_iam_policy" "github_actions_asg_refresh" {
  name        = "${var.project_name}-${var.environment}-github-actions-asg-refresh-policy"
  description = "Allow GitHub Actions to refresh frontend and backend ASGs"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowStartInstanceRefresh"
        Effect = "Allow"

        Action = [
          "autoscaling:StartInstanceRefresh",
          "autoscaling:DescribeInstanceRefreshes",
          "autoscaling:DescribeAutoScalingGroups"
        ]

        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-github-actions-asg-refresh-policy"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_asg_refresh" {
  role       = aws_iam_role.github_actions_ecr_push.name
  policy_arn = aws_iam_policy.github_actions_asg_refresh.arn
}


# -----------------------------
# IAM Policy for GitHub Actions Terraform Plan/Apply
# Learning/portfolio broad policy
# Later we can reduce this to least privilege
# -----------------------------
resource "aws_iam_policy" "github_actions_terraform" {
  name        = "${var.project_name}-github-actions-terraform-policy"
  description = "Allow GitHub Actions to run Terraform for this project"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "TerraformProjectAccess"
        Effect = "Allow"

        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "iam:*",
          "rds:*",
          "ecr:*",
          "route53:*",
          "acm:*",
          "s3:*",
          "dynamodb:*",
          "ssm:*",
          "logs:*",
          "cloudwatch:*",
          "sts:GetCallerIdentity"
        ]

        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-github-actions-terraform-policy"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform" {
  role       = aws_iam_role.github_actions_ecr_push.name
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}