terraform {
  backend "s3" {
    bucket = "terraform-streambox2"
    key    = "chef_wordpress"
    region = "us-west-2"
  }
}
