output "oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN."
  value       = var.existing_oidc_provider_arn
}

output "oidc_provider_url" {
  description = "GitHub Actions OIDC provider URL."
  value       = "https://token.actions.githubusercontent.com"
}

output "client_id_list" {
  description = "OIDC provider client IDs."
  value       = ["sts.amazonaws.com"]
}

output "github_actions_role_arns" {
  description = "IAM role ARNs assumed by GitHub Actions."
  value = {
    for env, role in aws_iam_role.github_actions :
    env => role.arn
  }
}

output "github_actions_role_names" {
  description = "IAM role names assumed by GitHub Actions."
  value = {
    for env, role in aws_iam_role.github_actions :
    env => role.name
  }
}

output "s3_bucket_names" {
  description = "Created S3 bucket names."
  value = {
    for env, bucket in aws_s3_bucket.site_bucket :
    env => bucket.bucket
  }
}

output "cloudfront_distribution_ids" {
  description = "CloudFront distribution IDs."
  value = {
    for env, distribution in aws_cloudfront_distribution.site :
    env => distribution.id
  }
}

output "cloudfront_distribution_domain_names" {
  description = "CloudFront distribution domain names."
  value = {
    for env, distribution in aws_cloudfront_distribution.site :
    env => distribution.domain_name
  }
}
