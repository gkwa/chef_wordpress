output "chef_wordpress.db_endpoint" {
  value = "${aws_db_instance.default.endpoint}"
}

output "chef_wordpress.domain" {
  value = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "chef_wordpress.bucket" {
  value = "${aws_s3_bucket.b1.bucket}"
}
