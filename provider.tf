provider "chef" {
  client_name  = "${var.chef_client_name}"
  server_url   = "${var.chef_server_url}"
}

provider "aws" {
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
  region     = "${var.region}"
}
