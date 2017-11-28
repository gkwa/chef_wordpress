provider "chef" {
  client_name  = "${var.chef_provider_client_name}"
  server_url   = "${var.chef_server_url}"
  key_material = "${file("~/.chef/mtm.pem")}"
}

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}
