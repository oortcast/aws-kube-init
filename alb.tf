resource "aws_lb" "gateway" {
  name = "${title(var.cluster_name)}Gateway"
  internal = "false"
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets = ["${split(",", var.dmz_subnet_ids)}"]
  enable_deletion_protection = "true"
  enable_cross_zone_load_balancing = "true"
  enable_http2 = "true"
  ip_address_type = "dualstack"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "aws_lb_target_group" "worker-nodes" {
  name = "${title(var.cluster_name)}WorkerNodes"
  port = 31380
  protocol = "HTTP"
  vpc_id = "${data.aws_vpc.selected.id}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "aws_lb_listener" "force_ssl" {
  load_balancer_arn = "${aws_lb.gateway.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
      type = "redirect"

      redirect {
          port = "443"
          protocol = "HTTPS"
          status_code = "HTTP_301"
      }
  }  
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = "${aws_lb.gateway.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-FS-2018-06"
  certificate_arn="${var.acm_cert_arn}"

  default_action {
      type = "forward"
      target_group_arn = "${aws_lb_target_group.worker-nodes.arn}"
  }  
}