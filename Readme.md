# AWS Kubernetes Init

This repository is used to deploy Kubernetes on AWS.

## Pre-requisites
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
* [Terraform CLI](https://www.terraform.io/intro/getting-started/install.html)
* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
* [Helm](https://helm.sh/docs/using_helm/#installing-helm)

## How to Run

Change AWS Resources:
```shell
terraform apply
```

Deploying applications with Helm:
```shell
helm install -f [custom_config_file] [application] 
```

## Docs
* [Terraform AWS Provider Docs](https://www.terraform.io/docs/providers/aws/)
* [Istio Docs](https://istio.io/docs/)