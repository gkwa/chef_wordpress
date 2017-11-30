data "template_file" "init" {
  template = <<EOF
  {
   "set_fqdn": "${var.fqdn}"
  }
  EOF

  vars {}
}
