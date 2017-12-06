resource "aws_s3_bucket" "b2" {
  bucket        = "${var.s3_backup_bucket}"
  acl           = "private"

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
    Name        = "${var.s3_backup_bucket}"
    Environment = "${terraform.workspace}"
  }
}
