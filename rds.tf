resource "aws_db_instance" "default" {
  identifier             = "chefwordpress"
  allocated_storage      = 5
  storage_type           = "gp2"
  engine                 = "mysql"
  instance_class         = "db.t2.small"
  username               = "${var.mysql_root_username}"
  password               = "${var.mysql_root_password}"
  db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
  vpc_security_group_ids = ["${aws_security_group.rdsSG.id}"]
  publicly_accessible    = true
  skip_final_snapshot    = true

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
  name_prefix = "chef_wordpress"
  description = "testing with chef_wordpress"
  subnet_ids  = ["${aws_subnet.private_1_subnet.id}", "${aws_subnet.private_2_subnet.id}"]
}

# https://goo.gl/RZfTkA
resource "aws_security_group" "rdsSG" {
  name        = "tutorial-db-securitygroup"
  description = "tutorial rds security group"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.FrontEnd.id}"]
  }
}
