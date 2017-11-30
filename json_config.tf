data "template_file" "init" {
  template = <<EOF
  {
    "db_endpoint": "$${db_endpoint}"
   ,"cloudfront_domain": "$${cloudfront_domain}"
   ,"set_fqdn": "${var.fqdn}"
  }
  EOF

  vars {
    db_endpoint       = "${aws_db_instance.default.endpoint}"
    cloudfront_domain = "${aws_s3_bucket.b1.bucket_domain_name}"
  }
}
