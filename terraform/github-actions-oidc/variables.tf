variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "resource_prefix" {
  description = "Prefix added to AWS resource names."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in the form owner/repo."
  type        = string
}

variable "github_oidc_thumbprint_list" {
  description = "Thumbprints for the GitHub Actions OIDC provider."
  type        = list(string)
}

variable "existing_oidc_provider_arn" {
  description = "Existing GitHub Actions OIDC provider ARN."
  type        = string
}

variable "environments" {
  description = "Per-environment AWS resources and allowed branches."
  type = map(object({
    role_name              = string
    s3_bucket_name         = string
    github_branches        = list(string)
    cloudfront_comment     = optional(string, "Static site distribution")
    cloudfront_price_class = optional(string, "PriceClass_200")
  }))
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}
