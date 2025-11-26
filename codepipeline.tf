# S3 Bucket for CodePipeline artifacts
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "codepipeline-artifacts-${var.environment}-${random_id.pipeline_suffix.hex}"
}

resource "aws_s3_bucket_acl" "codepipeline_artifacts" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  acl    = "private"
}

resource "random_id" "pipeline_suffix" {
  byte_length = 8
}

# IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "CodePipelineRole-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "CodePipelinePolicy-${var.environment}"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.codepipeline_artifacts.arn,
          "${aws_s3_bucket.codepipeline_artifacts.arn}/*",
          aws_s3_bucket.app_artifacts.arn,
          "${aws_s3_bucket.app_artifacts.arn}/*"
        ]
      },
      {
        Action = [
          "codestar-connections:UseConnection"
        ]
        Effect   = "Allow"
        Resource = var.codestar_connection_arn
      },
      {
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:RegisterApplicationRevision",
          "codedeploy:GetDeploymentConfig"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# CodeBuild Project for Infrastructure
resource "aws_codebuild_project" "infra_build" {
  name          = "infra-build-${var.environment}"
  description   = "Build project for infrastructure deployment"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = var.environment
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec-infra.yml")
  }

  tags = {
    Environment = var.environment
  }
}

# CodeBuild Project for Application
resource "aws_codebuild_project" "app_build" {
  name          = "app-build-${var.environment}"
  description   = "Build project for application deployment"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 30

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec-app.yml")
  }

  tags = {
    Environment = var.environment
  }
}

# IAM Role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "CodeBuildRole-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "CodeBuildPolicy-${var.environment}"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning",
          "s3:PutObject"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.codepipeline_artifacts.arn,
          "${aws_s3_bucket.codepipeline_artifacts.arn}/*",
          aws_s3_bucket.app_artifacts.arn,
          "${aws_s3_bucket.app_artifacts.arn}/*"
        ]
      },
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "ec2:CreateNetworkInterfacePermission"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = "*"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "cloudformation.amazonaws.com",
              "elasticbeanstalk.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

# CodePipeline
resource "aws_codepipeline" "main_pipeline" {
  name     = "main-pipeline-${var.environment}"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = var.codestar_connection_arn
        FullRepositoryId = var.github_repository
        BranchName       = var.github_branch
      }
    }
  }

  stage {
    name = "BuildInfrastructure"

    action {
      name             = "BuildInfrastructure"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["infra_output"]

      configuration = {
        ProjectName = aws_codebuild_project.infra_build.name
      }
    }
  }

  stage {
    name = "BuildApplication"

    action {
      name             = "BuildApplication"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["app_output"]

      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["app_output"]

      configuration = {
        ApplicationName     = aws_codedeploy_app.web_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.web_dg.deployment_group_name
      }
    }
  }

  tags = {
    Environment = var.environment
  }

  depends_on = [
    aws_codedeploy_app.web_app,
    aws_codedeploy_deployment_group.web_dg,
    aws_codebuild_project.infra_build,
    aws_codebuild_project.app_build
  ]
}

# CloudWatch Event to trigger pipeline on code changes
resource "aws_codepipeline_webhook" "webhook" {
  name            = "github-webhook-${var.environment}"
  authentication  = "GITHUB_HMAC"
  target_pipeline = aws_codepipeline.main_pipeline.name
  target_action   = "Source"

  authentication_configuration {
    secret_token = random_id.webhook_secret.hex
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/{Branch}"
  }
}

resource "random_id" "webhook_secret" {
  byte_length = 16
}

# Output the webhook URL for GitHub configuration
output "webhook_url" {
  description = "URL to configure in GitHub webhooks"
  value       = aws_codepipeline_webhook.webhook.url
  sensitive   = true
}

output "webhook_secret" {
  description = "Secret token for GitHub webhook"
  value       = random_id.webhook_secret.hex
  sensitive   = true
}

output "pipeline_url" {
  description = "URL to access CodePipeline"
  value       = "https://${var.aws_region}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${aws_codepipeline.main_pipeline.name}/view"
}

# Variables for CodePipeline
variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in format owner/repo"
  type        = string
  default     = "Joebaho/aws-codedeploy-terraform"
}

variable "github_branch" {
  description = "GitHub branch to monitor"
  type        = string
  default     = "main"
}