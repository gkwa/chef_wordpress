resource "aws_s3_bucket" "b1" {
  bucket = "${var.cloudfront_s3_bucket}"
  acl    = "public-read"

  versioning {
    enabled = true
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
    Environment = "${var.terraform_environment}"
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.b1.bucket_domain_name}"
    origin_id   = "chef_wordpress"
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
    Environment = "${var.terraform_environment}"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
