variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix added to AWS resource names."
  type        = string
}

variable "role_name" {
  description = "IAM role base name assumed by GitHub Actions."
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 bucket base name to create."
  type        = string
}

variable "transfer_user_name" {
  description = "Transfer Family user name."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in the form owner/repo."
  type        = string
}

variable "github_branches" {
  description = "Allowed branches for OIDC assumption."
  type        = list(string)
  default     = ["main"]
}

variable "github_oidc_thumbprint_list" {
  description = "Thumbprints for the GitHub Actions OIDC provider."
  type        = list(string)
}

variable "existing_oidc_provider_arn" {
  description = "Existing GitHub Actions OIDC provider ARN."
  type        = string
}

variable "cloudfront_comment" {
  description = "Comment for the CloudFront distribution."
  type        = string
  default     = "Static site distribution"
}

variable "cloudfront_price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_200"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
