resource "aws_eks_cluster" "cluster" {
  name = "${var.cluster_name}"
  role_arn = "${aws_iam_role.control_plane.arn}"
  version = "1.11"

  vpc_config = {
      subnet_ids = [
          "${split(",", var.worker_node_subnet_ids)}",
          "${split(",", var.dmz_subnet_ids)}"
      ]
      security_group_ids = ["${aws_security_group.control_plane.id}"]
  }

  depends_on = [
      "aws_iam_role_policy_attachment.eks_AmazonEKSClusterPolicy",
      "aws_iam_role_policy_attachment.eks_AmazonEKSServicePolicy"
  ]

}
