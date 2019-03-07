Add metrics-server and/or heapster to minikube:

```shell
minikube addons list
minikube addons enable heapster
minikube addons enable metrics-server
```

Add metrics-server to other clusters:

```shell
for f in aggregated-metrics-reader.yaml auth-delegator.yaml auth-reader.yaml metrics-apiservice.yaml metrics-server-deployment.yaml metrics-server-service.yaml resource-reader.yaml; do
  kubectl apply -f "https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/${f}"
done
```
