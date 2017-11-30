data "template_file" "init" {
  template = <<EOF
  {
    "db_endpoint": "$${db_endpoint}"
   ,"set_fqdn": "${var.fqdn}"
  }
  EOF

  vars {
    db_endpoint = "${aws_db_instance.default.endpoint}"
  }
}
