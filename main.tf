data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    vpc_name = "${var.vpc_name}"
    service_port = "${var.service_port}"
  }
}

resource "aws_launch_configuration" "service" {
  image_id        = "${var.service_image_id}"
  instance_type   = "${var.instance_type}"

  security_groups = ["${aws_security_group.instance.id}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "service" {
  launch_configuration = "${aws_launch_configuration.service.id}"
  availability_zones   = ["${data.aws_availability_zones.available.names[0]}"]
  vpc_zone_identifier =  ["${var.internal_subnet_id}"]

  load_balancers    = ["${aws_elb.service.name}"]
  health_check_type = "ELB"
  
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"

  tag {
    key                 = "Name"
    value               = "${var.vpc_name}-webserver-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  vpc_id = "${var.vpc_id}"
  name = "${var.vpc_name}-webserver-instance"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "instance_allow_http_inbound" {
  type = "ingress"
  security_group_id = "${aws_security_group.instance.id}"
  from_port   = "${var.service_port}"
  to_port     = "${var.service_port}"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_elb" "service" {
  name               = "${var.vpc_name}-webserver"
  security_groups    = ["${aws_security_group.elb.id}"]
  subnets            = ["${var.external_subnet_id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.service_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.service_port}/"
  }
}

resource "aws_security_group" "elb" {
  name = "webserver-elb"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "elb_allow_http_inbound" {
  type = "ingress"
  security_group_id = "${aws_security_group.elb.id}"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "elb_allow_all_outbound" {
  type = "egress"
  security_group_id = "${aws_security_group.elb.id}"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}