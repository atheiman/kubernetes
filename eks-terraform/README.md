# Deploy EKS in a new VPC with Terraform

## Prerequisites

Update `awscli` Python package to have latest `aws eks ...` commands: `pip install --upgrade pip awscli`

[`aws-iam-authenticator`](https://github.com/kubernetes-sigs/aws-iam-authenticator) is required to run `kubectl` commands: `brew install aws-iam-authenticator`

## Deploy base cluster with Terraform

Based off of [github.com/terraform-providers/terraform-provider-aws/examples/eks-getting-started](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started)

```shell
# build the vpc, eks cluster, and eks worker auto scaling group
terraform apply
```

Terraform apply will take 10-15 minutes. The Terraform output includes commands to run after to configure your workstation to interact with the new cluster.

> First `terraform apply` may fail with error below. Running `terraform apply` again moves past the error. I think it may be deploying the EKS cluster before all VPC resources are ready.
>
> ```
> * aws_eks_cluster.k8s: 1 error(s) occurred:
>
> * aws_eks_cluster.k8s: error creating EKS Cluster (<cluster-name>): InvalidParameterException: Error in role params
>   status code: 400, request id: f6201659-3839-11e9-827b-ff5d14f1c42c
> ```
