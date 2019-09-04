# Control Plane
resource "aws_security_group" "control_plane" {
  name = "${title(var.cluster_name)}_Control_Plane"
  description = "The security group of the cluster control plane."
  vpc_id = "${data.aws_vpc.selected.id}"

  egress {
      from_port = 0
      to_port = 65535
      description = "Allow the cluster control plane to communicate with worker nodes."
      protocol = "tcp"
      security_groups = ["${aws_security_group.worker_nodes.id}"]
  }

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "aws_security_group_rule" "control_plane_ingress_443" {
  type              = "ingress"
  security_group_id = "${aws_security_group.control_plane.id}"
  description       = "Allow pods to communicate with the cluster API Server."
  source_security_group_id = "${aws_security_group.worker_nodes.id}"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  
}

# Worker Nodes
resource "aws_security_group" "worker_nodes" {
  name = "${title(var.cluster_name)}_Worker_Nodes"
  description = "The security group for the ${var.cluster_name} worker node group."
  vpc_id = "${data.aws_vpc.selected.id}"

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
  }

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "aws_security_group_rule" "worker_nodes_ingress_each_other" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker_nodes.id}"
  description       = "Allow node to communicate with each other."
  source_security_group_id = "${aws_security_group.worker_nodes.id}"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
}

resource "aws_security_group_rule" "control_plane_to_worker_nodes" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker_nodes.id}"
  description       = "Allow worker Kubelets and pods to receive communication from the cluster control plane."
  source_security_group_id = "${aws_security_group.control_plane.id}"
  protocol          = "tcp"
  from_port         = 1025
  to_port           = 65535
}

resource "aws_security_group_rule" "worker_nodes_ingress_alb" {
  type              = "ingress"
  security_group_id = "${aws_security_group.worker_nodes.id}"
  description       = "Allow the worker pods to receive communication from ALB."
  source_security_group_id = "${aws_security_group.alb.id}"
  protocol          = "tcp"
  from_port         = 31380
  to_port           = 31400
}

# ALB
resource "aws_security_group" "alb" {
name = "${title(var.cluster_name)}_ALB"
  description = "The security group for the ${var.cluster_name} ALB."
  vpc_id = "${data.aws_vpc.selected.id}"

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
  }

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  security_group_id = "${aws_security_group.alb.id}"
  description       = "Allow http request."
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_security_group_rule" "alb_ssl" {
  type              = "ingress"
  security_group_id = "${aws_security_group.alb.id}"
  description       = "Allow https request."
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks = ["0.0.0.0/0"]
  ipv6_cidr_blocks = ["::/0"]
}
