variable "cluster_name" {}

variable "region" {}

variable "vpc_id" {}

variable "worker_node_subnet_ids" {}

variable "dmz_subnet_ids" {}

variable "min_worker_nodes_num" {}

variable "max_worker_nodes_num" {}

variable "worker_node_desired_capacity" {}

variable "image_id" {}

variable "key_name" {}

variable "acm_cert_arn" {}


provider "aws" {
    region = "${var.region}"
}

data "aws_vpc" "selected" {
    id= "${var.vpc_id}"
}

data "template_file" "worker_node_userdata" {
    template = "${file("${path.root}/worker_node_userdata.tpl")}"

    vars {
        cluster_name = "${var.cluster_name}"
    }
}

locals {
    # ref: https://blog.scottlowe.org/2018/06/11/using-variables-in-aws-tags-with-terraform/
    common_tags = "${map(
        "kubernetes.io/cluster/${var.cluster_name}", "owned",
    )}"
}
