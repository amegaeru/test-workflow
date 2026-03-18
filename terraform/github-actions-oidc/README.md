# GitHub Actions OIDC Terraform

This Terraform creates only the minimum AWS side for GitHub Actions OIDC.

It creates:

- a GitHub Actions OIDC provider
- an IAM role trusted by that provider
- `AmazonS3FullAccess` attached to the role

## Outputs

- `oidc_provider_arn`
- `oidc_provider_url`
- `client_id_list`
- `github_actions_role_arn`
- `github_actions_role_name`

## Example GitHub Actions step

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: actions/checkout@v4

  - name: Configure AWS credentials
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/github-actions-s3-fullaccess
      aws-region: ap-northeast-1
```
