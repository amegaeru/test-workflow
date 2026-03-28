# GitHub Actions OIDC Terraform

This Terraform creates the AWS resources required for GitHub Actions deployments for `dev`, `pre`, and `com`.

It creates, per environment:

- an S3 bucket for static assets
- a CloudFront distribution backed by that bucket
- an IAM role trusted by the existing GitHub Actions OIDC provider
- inline IAM policies for S3 deployment, backup rollback, and CloudFront invalidation

## Environment Inputs

Configure each environment under `environments` in `terraform.tfvars`.

Example:

```hcl
environments = {
  dev = {
    role_name              = "github-actions-dev"
    s3_bucket_name         = "test-static-site-dev-bucket-example"
    github_branches        = ["develop"]
    cloudfront_comment     = "test static site dev"
    cloudfront_price_class = "PriceClass_200"
  }
  pre = {
    role_name              = "github-actions-pre"
    s3_bucket_name         = "test-static-site-pre-bucket-example"
    github_branches        = ["main"]
    cloudfront_comment     = "test static site pre"
    cloudfront_price_class = "PriceClass_200"
  }
  com = {
    role_name              = "github-actions-com"
    s3_bucket_name         = "test-static-site-com-bucket-example"
    github_branches        = ["com"]
    cloudfront_comment     = "test static site com"
    cloudfront_price_class = "PriceClass_200"
  }
}
```

## Outputs

- `github_actions_role_arns`
- `github_actions_role_names`
- `s3_bucket_names`
- `cloudfront_distribution_ids`
- `cloudfront_distribution_domain_names`

## Example GitHub Actions step

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: actions/checkout@v6

  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v6
    with:
      role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
      aws-region: ${{ vars.AWS_REGION }}
```
