provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source        = "github.com/luddyte/tf_vpc.git?ref=v0.0.1"
  name          = "demo_stack"
  cidr          = "10.0.0.0/16"
  public_subnet = "10.0.1.0/24"
}

#data "template_file" "index" {
#count    = "${length(var.instance_ips)}"
#template = "${file("files/index.html.tpl")}"

#vars {
#  hostname = "web-${format("%03d", count.index + 1)}"
#}
#}

## Machines
resource "aws_instance" "web" {
  ami           = "${lookup(var.ami, var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${module.vpc.public_subnet_id}"
  private_ip    = "${var.web_ips[count.index]}"

  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.web_host_sg.id}",
  ]

  tags {
    Name = "web-${format("%03d", count.index + 1)}"
  }

  count = "${length(var.web_ips)}"

  connection {
    user  = "ubuntu"
    agent = true     # use ssh_agent

    #private_key = "${file(var.key_path)}" # encrypted keys not supported, don't use
  }

  provisioner "file" {
    source      = "files/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
     "chmod +x /tmp/bootstrap_puppet.sh /tmp/bootstrap_agent.sh",
     "sudo /tmp/bootstrap_puppet.sh",
     "sudo /tmp/bootstrap_agent.sh"
     ]
  }
}

resource "aws_instance" "db" {
  ami           = "${lookup(var.ami, var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${module.vpc.public_subnet_id}"
  private_ip    = "${var.db_ips[count.index]}"

  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.web_host_sg.id}",
  ]

  tags {
    Name = "db-${format("%03d", count.index + 1)}"
  }

  count = "${length(var.db_ips)}"

  connection {
    user  = "ubuntu"
    agent = true     # use ssh_agent

    #private_key = "${file(var.key_path)}" # encrypted keys not supported, don't use
  }

  provisioner "file" {
    source      = "files/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
     "chmod +x /tmp/bootstrap_puppet.sh /tmp/bootstrap_agent.sh /tmp/bootstrap_db.sh",
     "sudo /tmp/bootstrap_puppet.sh",
     "sudo /tmp/bootstrap_agent.sh",
     "sudo /tmp/bootstrap_db.sh"
     ]
  }
}

resource "aws_instance" "server" {
  ami           = "${lookup(var.ami, var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  subnet_id     = "${module.vpc.public_subnet_id}"
  private_ip    = "${var.server_ips[count.index]}"

  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.web_host_sg.id}",
  ]

  tags {
    Name = "server-${format("%03d", count.index + 1)}"
    Role = "server"
  }

  count = "${length(var.server_ips)}"

  connection {
    user  = "ubuntu"
    agent = true     # use ssh_agent
  }

  provisioner "file" {
    source      = "files/"
    destination = "/tmp"
  }

  provisioner "remote-exec" {
    inline = [
     "chmod +x /tmp/bootstrap_puppet.sh bootstrap_server.sh",
     "sudo /tmp/bootstrap_puppet.sh",
     "sudo /tmp/bootstrap_server.sh"
     ]
  }

  provisioner "file" {
    source      = "../services/"
    destination = "~/jobs"
  }
}

resource "aws_elb" "web" {
  name            = "web-elb"
  subnets         = ["${module.vpc.public_subnet_id}"]
  security_groups = ["${aws_security_group.web_inbound_sg.id}"]

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 3000
    lb_protocol       = "http"
  }

  # The instances are registered automatically
  instances = ["${aws_instance.web.*.id}"]
}

resource "aws_security_group" "web_inbound_sg" {
  name        = "web_inbound"
  description = "Allow HTTP from Anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_host_sg" {
  name        = "web_host"
  description = "Allow SSH & HTTP to web hosts"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${module.vpc.cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
