output "elb_address" {
  value = "${aws_elb.web.dns_name}"
}

output "web_addresses" {
  value = ["${aws_instance.web.*.public_ip}"]
}

output "server_address" {
  value = ["${aws_instance.server.public_ip}"]
}

output "db_address" {
  value = ["${aws_instance.db.public_ip}"]
}

output "public_subnet_id" {
  value = "${module.vpc.public_subnet_id}"
}
