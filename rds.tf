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
  publicly_accessible  = true
  skip_final_snapshot  = true

  tags {
    name = "chef_wordpress"
  }
}

provider "mysql" {
  endpoint = "${aws_db_instance.default.endpoint}"
  username = "${aws_db_instance.default.username}"
  password = "${aws_db_instance.default.password}"
}

resource "aws_db_subnet_group" "default" {
  name        = "chef_wordpress"
  description = "testing with chef_wordpress"
  subnet_ids  = ["${aws_subnet.private_1_subnet.id}", "${aws_subnet.private_2_subnet.id}"]
}

resource "aws_db_security_group" "default" {
  name = "chef_wordpress"

  ingress {
    security_group_id = "${aws_security_group.FrontEnd.id}"
  }
}
