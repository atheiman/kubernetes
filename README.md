# Kubernetes Notes and Examples

## Prerequisites

Update `awscli` Python package to have latest `aws eks ...` commands: `pip install --upgrade pip awscli`

[`aws-iam-authenticator`](https://github.com/kubernetes-sigs/aws-iam-authenticator) is required to run `kubectl` commands: `brew install aws-iam-authenticator`

## Deploy base cluster with Terraform

Based off of [github.com/terraform-providers/terraform-provider-aws/examples/eks-getting-started](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started)


## Useful resources

- Guestbook PHP app example stateless application: https://kubernetes.io/docs/tutorials/stateless-application/guestbook/
