output "elb_dns_name" {
  value = "${aws_elb.service.dns_name}"
}