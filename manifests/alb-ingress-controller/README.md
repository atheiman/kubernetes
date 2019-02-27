[`eks-terraform/`](../eks-terraform/) creates a cluster with [aws-alb-ingress-controller](https://github.com/kubernetes-sigs/aws-alb-ingress-controller/) included. [`nginx.yaml`](./nginx.yaml) creates an nginx deployment, internal service, and ingress exposed to the internet.

```shell
# Create nginx deployment, NodePort service, and ingress
kubectl apply -f nginx.yaml

# Get the address of the created AWS ALB
kubectl get ingress

# nginx should respond through the ALB after DNS propagates (takes a few min)
```
