# resource "aws_iam_openid_connect_provider" "github_actions" {
#   url             = "https://token.actions.githubusercontent.com"
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = var.github_oidc_thumbprint_list
#
#   tags = var.tags
# }

# resource "tls_private_key" "transfer_family" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

resource "aws_s3_bucket" "site_bucket" {
  bucket = "${var.resource_prefix}${var.s3_bucket_name}"
  tags   = var.tags
}

resource "aws_s3_bucket_public_access_block" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "site_bucket" {
  name                              = "${var.resource_prefix}${var.s3_bucket_name}-oac"
  description                       = "OAC for ${var.resource_prefix}${var.s3_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cloudfront_comment
  default_root_object = "index.html"
  price_class         = var.cloudfront_price_class

  origin {
    domain_name              = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.site_bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.site_bucket.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.site_bucket.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [aws_s3_bucket_public_access_block.site_bucket]

  tags = var.tags
}

data "aws_iam_policy_document" "site_bucket_policy" {
  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.site_bucket.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site_bucket" {
  bucket = aws_s3_bucket.site_bucket.id
  policy = data.aws_iam_policy_document.site_bucket_policy.json
}

data "aws_iam_policy_document" "github_actions_trust" {
  statement {
    sid     = "GitHubActionsAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.existing_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        for branch in var.github_branches :
        "repo:${var.github_repository}:ref:refs/heads/${branch}"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.resource_prefix}${var.role_name}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust.json
  tags               = var.tags
}

data "aws_iam_policy_document" "github_actions_s3" {
  statement {
    sid    = "AllowBucketMetadata"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.site_bucket.arn
    ]
  }

  statement {
    sid    = "AllowJsObjectManagement"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.site_bucket.arn}/js/*"
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_s3" {
  name   = "${var.resource_prefix}${var.role_name}-s3"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_s3.json
}

data "aws_iam_policy_document" "github_actions_cloudfront" {
  statement {
    sid    = "AllowCreateInvalidation"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      aws_cloudfront_distribution.site.arn
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_cloudfront" {
  name   = "${var.resource_prefix}${var.role_name}-cloudfront"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.github_actions_cloudfront.json
}

# data "aws_iam_policy_document" "transfer_family_trust" {
#   statement {
#     effect  = "Allow"
#     actions = ["sts:AssumeRole"]
#
#     principals {
#       type        = "Service"
#       identifiers = ["transfer.amazonaws.com"]
#     }
#   }
# }
#
# resource "aws_iam_role" "transfer_family_access" {
#   name               = "${var.resource_prefix}transfer-family-access"
#   assume_role_policy = data.aws_iam_policy_document.transfer_family_trust.json
#   tags               = var.tags
# }
#
# data "aws_iam_policy_document" "transfer_family_access" {
#   statement {
#     sid    = "ListBucket"
#     effect = "Allow"
#     actions = [
#       "s3:GetBucketLocation",
#       "s3:ListBucket"
#     ]
#     resources = [aws_s3_bucket.site_bucket.arn]
#   }
#
#   statement {
#     sid    = "ManageHtmlObjects"
#     effect = "Allow"
#     actions = [
#       "s3:DeleteObject",
#       "s3:GetObject",
#       "s3:PutObject"
#     ]
#     resources = [
#       "${aws_s3_bucket.site_bucket.arn}/html/*"
#     ]
#   }
# }
#
# resource "aws_iam_role_policy" "transfer_family_access" {
#   name   = "${var.resource_prefix}transfer-family-access"
#   role   = aws_iam_role.transfer_family_access.id
#   policy = data.aws_iam_policy_document.transfer_family_access.json
# }
#
# resource "aws_transfer_server" "site_upload" {
#   endpoint_type          = "PUBLIC"
#   identity_provider_type = "SERVICE_MANAGED"
#   protocols              = ["SFTP"]
#   security_policy_name   = "TransferSecurityPolicy-2023-05"
#
#   tags = var.tags
# }
#
# resource "aws_transfer_user" "site_upload" {
#   server_id      = aws_transfer_server.site_upload.id
#   user_name      = var.transfer_user_name
#   role           = aws_iam_role.transfer_family_access.arn
#   home_directory = "/${aws_s3_bucket.site_bucket.bucket}/html"
#
#   tags = var.tags
# }
#
# resource "aws_transfer_ssh_key" "site_upload" {
#   server_id = aws_transfer_server.site_upload.id
#   user_name = aws_transfer_user.site_upload.user_name
#   body      = tls_private_key.transfer_family.public_key_openssh
# }

