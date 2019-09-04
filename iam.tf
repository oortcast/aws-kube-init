# Control Plane
data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "control_plane" {
  name        = "${title(var.cluster_name)}_Control_Plane"
  description        = "Allows ${var.cluster_name} to manage clusters on your behalf."
  assume_role_policy = "${data.aws_iam_policy_document.eks_assume_role_policy.json}"

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.control_plane.name}"
}

resource "aws_iam_role_policy_attachment" "eks_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.control_plane.name}"
}




# Worker Nodes
resource "aws_iam_role" "worker_nodes" {
    name               = "${title(var.cluster_name)}_Worker_Nodes"
    description        = "Allow ${var.cluster_name} EC2 Worker nodes to call AWS services on your behalf."
    path               = "/"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = "${merge(
    local.common_tags,
    map()
  )}"
}

resource "aws_iam_instance_profile" "work_node_iam_profile"{
  name ="${aws_iam_role.worker_nodes.name}"
  role = "${aws_iam_role.worker_nodes.name}"

}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy-policy-attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role      = "${aws_iam_role.worker_nodes.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly-policy-attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role      = "${aws_iam_role.worker_nodes.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy-policy-attachment" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role      = "${aws_iam_role.worker_nodes.name}"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforSSM-policy-attachment" {
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
    role      = "${aws_iam_role.worker_nodes.name}"
}
