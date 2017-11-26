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

variable "mysql_root_password" {
  type = "string"
}

variable "mysql_root_username" {
  type = "string"
}

variable "aws_access_key_id" {
  type = "string"
}

variable "aws_secret_access_key" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "terraform_environment" {
  type = "string"
}

variable "terraform_wordpress_backup_s3_bucket" {
  type = "string"
}

variable "terraform_cloudfront_s3_bucket" {
  type = "string"
}

variable "cloudfront_cname" {
  type = "string"
}

variable "origin_access_identity" {
  type = "string"
}

variable "streambox_zone_id" {
  type = "string"

  default = "ZYM2WVE2N8MU5"
}

variable "fqdn" {
  type = "string"
}
