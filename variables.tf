variable "mysql_wordpress_password" {}
variable "mysql_wordpress_username" {}
variable "chef_provider_client_name" {}

variable "chef_server_url" {
  default = "https://chef.streambox.com/organizations/streambox/"
}

variable "provisioner_chef_user_key" {
  description = "PEM key to enable chef-client to connect to chef server"
  default     = "~/.chef/mtm.pem"
}

variable "public_key_path" {
  description = "Enter the path to the SSH Public Key to add to AWS."
  default     = "~/.ssh/aws_keys/StreamboxLive-California.pub"
}

variable "private_key_path" {
  description = "Enter the path to the SSH Private Key to run provisioner."
  default     = "~/.ssh/aws_keys/StreamboxLive-California.pem"
}

variable "mysql_root_password" {}
variable "mysql_root_username" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "region" {}
variable "terraform_environment" {}
variable "s3_backup_bucket" {}
variable "cloudfront_s3_bucket" {}
variable "cloudfront_cname" {}
variable "fqdn" {}

variable "streambox_zone_id" {
  default = "ZYM2WVE2N8MU5"
}
