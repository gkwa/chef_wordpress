resource "aws_vpc" "default" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "tutorial-vpc"
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = "${aws_vpc.default.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Default Routing Table (chef_wordpress)"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-west-1c"

  tags {
    Name = "Tutorial public"
  }
}

resource "aws_subnet" "private_1_subnet" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-1c"

  tags {
    Name = "Tutorial Private 1"
  }
}

resource "aws_subnet" "private_2_subnet" {
  vpc_id            = "${aws_vpc.default.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-1b"

  tags {
    Name = "Tutorial Private 2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "IGW (chef_wordpress)"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "Private Route Table (chef_wordpress)"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_vpc.default.main_route_table_id}"
}

resource "aws_route_table_association" "private_1_subnet_association" {
  subnet_id      = "${aws_subnet.private_1_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "private_2_subnet_association" {
  subnet_id      = "${aws_subnet.private_2_subnet.id}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-17.04-amd64*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "auth" {
  key_name_prefix = "StreamboxLive-California-"
  public_key      = "${file(var.public_key_path)}"
}

resource "aws_instance" "web" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${aws_subnet.public_subnet.id}"
  associate_public_ip_address = true
  depends_on                  = ["aws_internet_gateway.gw"]
  vpc_security_group_ids      = ["${aws_security_group.FrontEnd.id}"]
  key_name                    = "${aws_key_pair.auth.id}"

  volume_tags {
    Name = "chef_wordpress"
  }

  root_block_device {
    volume_size = "50"
  }

  provisioner "file" {
    source      = "conf/myapp.conf"
    destination = "/tmp/myapp.conf"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp -R /home/ubuntu/.ssh /root",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.private_key_path)}"
    }
  }

  provisioner "chef" {
    connection {
      type        = "ssh"
      user        = "root"
      private_key = "${file(var.private_key_path)}"
    }

    attributes_json = "${join("\n", data.template_file.init.*.rendered)}"
    environment     = "${terraform.workspace}"
    run_list        = ["chef_wordpress::hosts"]
    node_name       = "${var.node_name}"
    secret_key      = "${file("~/.chef/encrypted_data_bag_secret")}"
    server_url      = "https://chef.streambox.com/organizations/streambox"
    recreate_client = true
    user_name       = "mtm"
    user_key        = "${file(var.provisioner_chef_user_key)}"
    ssl_verify_mode = ":verify_peer"
  }

  tags {
    Name      = "wordpress"
    Backup    = ""
    Retention = "4"
  }
}

resource "aws_route53_record" "web" {
  zone_id = "${var.streambox_zone_id}"
  name    = "${var.fqdn}"
  type    = "A"

  ttl     = "3600"
  records = ["${aws_instance.web.public_ip}"]
}

resource "aws_route53_record" "webtest" {
  zone_id = "${var.streambox_zone_id}"
  name    = "${var.cloudfront_cname}"
  type    = "CNAME"
  ttl     = "3600"

  records = ["${aws_cloudfront_distribution.s3_distribution.domain_name}"]
}

resource "aws_security_group" "FrontEnd" {
  name = "chef_wordpress"

  tags {
    Name = "chef_wordpress"
  }

  description = "chef_wordpress"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
