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

output "github_actions_role_arn" {
  description = "IAM role ARN assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "IAM role name assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.name
}

output "s3_bucket_name" {
  description = "Created S3 bucket name."
  value       = aws_s3_bucket.site_bucket.bucket
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_distribution_domain_name" {
  description = "CloudFront distribution domain name."
  value       = aws_cloudfront_distribution.site.domain_name
}

# output "transfer_server_id" {
#   description = "AWS Transfer Family server ID."
#   value       = aws_transfer_server.site_upload.id
# }
#
# output "transfer_server_endpoint" {
#   description = "AWS Transfer Family server endpoint."
#   value       = aws_transfer_server.site_upload.endpoint
# }
#
# output "transfer_user_name" {
#   description = "AWS Transfer Family user name."
#   value       = aws_transfer_user.site_upload.user_name
# }
#
# output "transfer_user_public_key" {
#   description = "Generated SSH public key for the Transfer Family user."
#   value       = tls_private_key.transfer_family.public_key_openssh
# }
#
# output "transfer_user_private_key_pem" {
#   description = "Generated SSH private key for the Transfer Family user."
#   value       = tls_private_key.transfer_family.private_key_pem
#   sensitive   = true
# }

