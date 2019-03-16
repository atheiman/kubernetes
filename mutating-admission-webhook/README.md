# Mutating Webhook Admission Controller Example

Build the docker image in minikube:

```shell
eval $(minikube docker-env)
docker build -t mutating-admission-webhook .
# Sending build context to Docker daemon  20.13MB
# Step 1/12 : FROM golang:alpine AS build-env
# alpine: Pulling from library/golang
# ...
# Successfully built 594adc0d0891
# Successfully tagged mutating-admission-webhook:latest
```

Create a namespace for the mutating admission webhook

```shell
kubectl create ns mutating-admission-webhook
# namespace/mutating-admission-webhook created
```

Create a cert and key secret in your cluster for the webhook service:

```shell
./gen-cert.sh
# creating certs in tmpdir ...
# ...
# secret/mutating-admission-webhook created
```

Update `caBundle` in the `MutatingWebhookConfiguration` in `manifest.yaml`:

```shell
kubectl get configmap -n kube-system extension-apiserver-authentication -o=jsonpath='{.data.client-ca-file}' | base64 | tr -d '\n'
```

Create the `MutatingWebhookConfiguration` and its `Deployment` and `Service`:

```shell
kubectl apply -f manifest.yaml
# service/mutating-admission-webhook created
# deployment.apps/mutating-admission-webhook created
# mutatingwebhookconfiguration.admissionregistration.k8s.io/mutating-admission-webhook created
```

Launch a pod in a new namespace to see the mutating admission webhook apply a new label to the pod. The namespace has a label specified by the `namespaceSelector` in the `MutatingWebhookConfiguration`. The pod should receive a label `thisisanewlabel=hello` applied by the mutating admission webhook:

```shell
kubectl apply -f test.yaml
# namespace/mwc-test created
# pod/pause created
kubectl get po -n mwc-test --show-labels
# NAME    READY   STATUS    RESTARTS   AGE   LABELS
# pause   1/1     Running   0          89s   test=label,thisisanewlabel=hello
```

You can also see a log message from the mutating-admission-webhook pod:

```shell
kubectl logs -n mutating-admission-webhook mutating-admission-webhook-5899cdb6-q5kqm
# time="2019-03-16T20:33:17Z" level=info msg="adding label to pod"
# time="2019-03-16T20:33:17Z" level=info msg="added patch [{\"op\":\"add\",\"path\":\"/metadata/labels/thisisanewlabel\", \"value\":\"hello\"}]"
# time="2019-03-16T20:33:17Z" level=info msg="{\"response\":{\"uid\":\"bb0bab39-482a-11e9-8ed6-0800275d5ebf\",\"allowed\":true,\"patch\":\"W3sib3AiOiJhZGQiLCJwYXRoIjoiL21ldGFkYXRhL2xhYmVscy90aGlzaXNhbmV3bGFiZWwiLCAidmFsdWUiOiJoZWxsbyJ9XQ==\",\"patchType\":\"JSONPatch\"}}"
# time="2019-03-16T20:33:17Z" level=info msg="Writing response"
```

## Credits

Adapted from https://container-solutions.com/some-admission-webhook-basics/ / https://github.com/jasonrichardsmith/mwcexample.
