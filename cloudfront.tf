resource "aws_s3_bucket" "b1" {
  bucket        = "${var.cloudfront_s3_bucket}"
  acl           = "public-read"
  force_destroy = true

  versioning {
    enabled = true
  }

  cors_rule {
    allowed_origins = ["*.streambox.com"]
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    max_age_seconds = 3000
  }

  lifecycle_rule {
    id                                     = "delete old"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 7

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = 60
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }

  tags {
    Name        = "${var.cloudfront_s3_bucket}"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${var.fqdn}"
    origin_id   = "chef_wordpress"

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      http_port              = "80"
      https_port             = "443"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  aliases = ["${var.cloudfront_cname}"]

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "chef_wordpress"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags {
    Environment = "${terraform.workspace}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
