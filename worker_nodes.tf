resource "aws_autoscaling_group" "worker_nodes" {
  name = "${title(var.cluster_name)}_Worker_Nodes"
  max_size = "${var.max_worker_nodes_num}"
  min_size = "${var.min_worker_nodes_num}"
  desired_capacity = "${var.worker_node_desired_capacity}"
  placement_group = "${aws_placement_group.worker_nodes.name}"
  launch_configuration      = "${aws_launch_configuration.worker_nodes.name}"
  health_check_grace_period = "300"
  health_check_type = "EC2"
  target_group_arns = ["${aws_lb_target_group.worker-nodes.arn}"]
  vpc_zone_identifier = ["${split(",", var.worker_node_subnet_ids)}"]
  termination_policies = ["Default"]
  default_cooldown = "60"

  tag {
    key                 = "Name"
    value               = "${title(var.cluster_name)}_Worker_Node"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

resource "aws_placement_group" "worker_nodes" {
  name     = "${title(var.cluster_name)}_Worker_Nodes_Placement"
  strategy = "spread"
}

resource "aws_launch_configuration" "worker_nodes" {
  name     = "${title(var.cluster_name)}_Worker_Nodes"
  image_id = "${var.image_id}"
  instance_type = "t3.2xlarge"
  iam_instance_profile = "${aws_iam_instance_profile.work_node_iam_profile.name}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.worker_nodes.id}"]

  lifecycle {
    create_before_destroy = true
  }

  ebs_optimized = true
  enable_monitoring = true
  user_data="${data.template_file.worker_node_userdata.rendered}"

  root_block_device {
    volume_size           = "30"
    volume_type           = "gp2"
    delete_on_termination = "true"
  }

}