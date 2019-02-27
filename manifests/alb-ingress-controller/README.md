[`eks-terraform/`](../eks-terraform/) creates a cluster with [aws-alb-ingress-controller](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/) included. [`nginx.yaml`](./nginx.yaml) creates an nginx deployment, internal service, and ingress exposed to the internet.

```shell
kubectl apply -f nginx.yaml
```
