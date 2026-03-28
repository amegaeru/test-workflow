locals {
  environments = var.environments
}

resource "aws_s3_bucket" "site_bucket" {
  for_each = local.environments

  bucket = "${var.resource_prefix}${each.value.s3_bucket_name}"
  tags   = merge(var.tags, { Environment = each.key })
}

resource "aws_s3_bucket_public_access_block" "site_bucket" {
  for_each = local.environments

  bucket = aws_s3_bucket.site_bucket[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "site_bucket" {
  for_each = local.environments

  name                              = "${var.resource_prefix}${each.value.s3_bucket_name}-oac"
  description                       = "OAC for ${var.resource_prefix}${each.value.s3_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "site" {
  for_each = local.environments

  enabled             = true
  is_ipv6_enabled     = true
  comment             = each.value.cloudfront_comment
  default_root_object = "index.html"
  price_class         = each.value.cloudfront_price_class

  origin {
    domain_name              = aws_s3_bucket.site_bucket[each.key].bucket_regional_domain_name
    origin_id                = aws_s3_bucket.site_bucket[each.key].id
    origin_access_control_id = aws_cloudfront_origin_access_control.site_bucket[each.key].id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.site_bucket[each.key].id
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

  tags = merge(var.tags, { Environment = each.key })
}

data "aws_iam_policy_document" "site_bucket_policy" {
  for_each = local.environments

  statement {
    sid    = "AllowCloudFrontRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.site_bucket[each.key].arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site[each.key].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "site_bucket" {
  for_each = local.environments

  bucket = aws_s3_bucket.site_bucket[each.key].id
  policy = data.aws_iam_policy_document.site_bucket_policy[each.key].json
}

data "aws_iam_policy_document" "github_actions_trust" {
  for_each = local.environments

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
        "repo:${var.github_repository}:environment:${each.value.github_environment}"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  for_each = local.environments

  name               = "${var.resource_prefix}${each.value.role_name}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_trust[each.key].json
  tags               = merge(var.tags, { Environment = each.key })
}

data "aws_iam_policy_document" "github_actions_s3" {
  for_each = local.environments

  statement {
    sid    = "AllowBucketMetadata"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.site_bucket[each.key].arn
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
      "${aws_s3_bucket.site_bucket[each.key].arn}/js/*",
      "${aws_s3_bucket.site_bucket[each.key].arn}/backup/js-previous/*"
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_s3" {
  for_each = local.environments

  name   = "${var.resource_prefix}${each.value.role_name}-s3"
  role   = aws_iam_role.github_actions[each.key].id
  policy = data.aws_iam_policy_document.github_actions_s3[each.key].json
}

data "aws_iam_policy_document" "github_actions_cloudfront" {
  for_each = local.environments

  statement {
    sid    = "AllowCreateInvalidation"
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      aws_cloudfront_distribution.site[each.key].arn
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_cloudfront" {
  for_each = local.environments

  name   = "${var.resource_prefix}${each.value.role_name}-cloudfront"
  role   = aws_iam_role.github_actions[each.key].id
  policy = data.aws_iam_policy_document.github_actions_cloudfront[each.key].json
}
