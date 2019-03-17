# Mutating Webhook Admission Controller Example

The docker image has been built and pushed to [`atheiman/sinatra-mutating-webhook`](https://cloud.docker.com/u/atheiman/repository/docker/atheiman/sinatra-mutating-webhook).

Create a namespace for the mutating webhook:

```shell
kubectl create ns sinatra-mutating-webhook
```

Create a cert and key secret in your cluster for the webhook service:

```shell
title="sinatra-mutating-webhook" ./gen-cert.sh
```

Update `caBundle` in the `MutatingWebhookConfiguration` in `manifest.yaml`:

```shell
kubectl get configmap -n kube-system extension-apiserver-authentication -o=jsonpath='{.data.client-ca-file}' | base64 | tr -d '\n'
```

Create the `MutatingWebhookConfiguration` and its `Deployment` and `Service`:

```shell
kubectl apply -f manifest.yaml
```

Launch a pod in a new namespace to see the mutating admission webhook apply a new label to the pod. The namespace has a label specified by the `namespaceSelector` in the `MutatingWebhookConfiguration`. The pod should receive a label `fun=hello` applied by the mutating webhook:

```shell
kubectl apply -f test.yaml
kubectl get po -n sinatra-mutating-webhook-test --show-labels
```

You can also see a log message from the sinatra-mutating-webhook pod:

```shell
kubectl logs -n sinatra-mutating-webhook sinatra-mutating-webhook-5899cdb6-q5kqm
```

## Credits

Adapted from https://container-solutions.com/some-admission-webhook-basics/ / https://github.com/jasonrichardsmith/mwcexample.
