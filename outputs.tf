output "load_balancer_url" {
  description = "URL to access the web application"
  value       = "http://${aws_lb.web_alb.dns_name}"
}

output "codedeploy_app_name" {
  description = "Name of the CodeDeploy application"
  value       = aws_codedeploy_app.web_app.name
}

output "codedeploy_deployment_group" {
  description = "Name of the CodeDeploy deployment group"
  value       = aws_codedeploy_deployment_group.web_dg.deployment_group_name
}

output "s3_bucket_artifacts" {
  description = "Name of the S3 bucket for application artifacts"
  value       = aws_s3_bucket.app_artifacts.bucket
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}