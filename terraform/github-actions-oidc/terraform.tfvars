aws_region = "ap-northeast-1"

resource_prefix = "takahashi-"

github_repository          = "amegaeru/test-workflow"
existing_oidc_provider_arn = "arn:aws:iam::832194395201:oidc-provider/token.actions.githubusercontent.com"

github_oidc_thumbprint_list = [
  "6938fd4d98bab03faadb97b34396831e3780aea1"
]

environments = {
  dev = {
    role_name              = "github-actions-dev"
    s3_bucket_name         = "test-static-site-dev-bucket-example"
    github_branches        = ["dev"]
    cloudfront_comment     = "test static site dev"
    cloudfront_price_class = "PriceClass_200"
  }
  pre = {
    role_name              = "github-actions-pre"
    s3_bucket_name         = "test-static-site-pre-bucket-example"
    github_branches        = ["pre"]
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

tags = {
  Project = "test"
  Managed = "terraform"
}
