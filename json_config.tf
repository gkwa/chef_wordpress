data "template_file" "init" {
  template = <<EOF
  {
    "db_endpoint": "$${db_endpoint}"
   ,"cloudfront_domain_name": "$${cloudfront_domain_name}"
   ,"cloudfront_cname": "${var.cloudfront_cname}"
   ,"cloudfront_domain": "$${cloudfront_domain}"
   ,"set_fqdn": "${var.fqdn}"
  }
  EOF

  vars {
    cloudfront_domain_name = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    db_endpoint            = "${aws_db_instance.default.endpoint}"
    cloudfront_domain      = "${aws_s3_bucket.b1.bucket_domain_name}"
  }
}
