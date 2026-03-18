aws_region = "ap-northeast-1"

resource_prefix    = "takahashi-"
role_name          = "github-actions-s3-fullaccess"
s3_bucket_name     = "test-static-site-bucket-example"
transfer_user_name = "html-uploader"

github_repository          = "amegaeru/test-workflow"
github_branches            = ["main"]
existing_oidc_provider_arn = "arn:aws:iam::832194395201:oidc-provider/token.actions.githubusercontent.com"

github_oidc_thumbprint_list = [
  "6938fd4d98bab03faadb97b34396831e3780aea1"
]

cloudfront_comment     = "test static site"
cloudfront_price_class = "PriceClass_200"

tags = {
  Project = "test"
  Managed = "terraform"
}
