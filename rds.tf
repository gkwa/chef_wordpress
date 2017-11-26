resource "aws_db_instance" "default" {
  identifier           = "chefwordpress"
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  instance_class       = "db.t2.micro"
  name                 = "chef_wordpress"
  username             = "${var.mysql_root_username}"
  password             = "${var.mysql_root_password}"
  db_subnet_group_name = "${aws_db_subnet_group.default.id}"
  publicly_accessible  = false
  skip_final_snapshot  = true

  tags {
    name = "chef_wordpress"
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "chef_wordpress"
  description = "Our main group of subnets"
  subnet_ids  = ["${aws_subnet.private_1_subnet.id}", "${aws_subnet.private_2_subnet.id}"]
}

resource "aws_db_security_group" "default" {
  name = "chef_wordpress"

  ingress {
    cidr = "${aws_instance.web.private_ip}/32"
  }
}