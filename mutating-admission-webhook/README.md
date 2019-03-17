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
# pod/has-labels created
# pod/no-labels created
# pod/excluded created
kubectl get po -n mwc-test --show-labels
# NAME         READY   STATUS    RESTARTS   AGE   LABELS
# excluded     1/1     Running   0          5s    <none>
# has-labels   1/1     Running   0          6s    test=label,thisisanewlabel=hello
# no-labels    1/1     Running   0          5s    thisisanewlabel=hello
```

You can also see a log message from the mutating-admission-webhook pod:

```shell
kubectl logs -n mutating-admission-webhook mutating-admission-webhook-5899cdb6-q5kqm
# time="2019-03-16T22:19:16Z" level=info msg="adding label to pod"
# time="2019-03-16T22:19:16Z" level=info msg="added patch [{\"op\":\"add\",\"path\":\"/metadata/labels/thisisanewlabel\", \"value\":\"hello\"}]"
# time="2019-03-16T22:19:16Z" level=info msg="{\"response\":{\"uid\":\"8989fbf9-4839-11e9-94c6-08002749fc69\",\"allowed\":true,\"patch\":\"W3sib3AiOiJhZGQiLCJwYXRoIjoiL21ldGFkYXRhL2xhYmVscy90aGlzaXNhbmV3bGFiZWwiLCAidmFsdWUiOiJoZWxsbyJ9XQ==\",\"patchType\":\"JSONPatch\"}}"
# time="2019-03-16T22:19:16Z" level=info msg="Writing response"
# time="2019-03-16T22:19:17Z" level=info msg="adding label to pod"
# time="2019-03-16T22:19:17Z" level=info msg="added patch [{\"op\":\"add\",\"path\":\"/metadata/labels\", \"value\":{\"thisisanewlabel\":\"hello\"}}]"
# time="2019-03-16T22:19:17Z" level=info msg="{\"response\":{\"uid\":\"8998522f-4839-11e9-94c6-08002749fc69\",\"allowed\":true,\"patch\":\"W3sib3AiOiJhZGQiLCJwYXRoIjoiL21ldGFkYXRhL2xhYmVscyIsICJ2YWx1ZSI6eyJ0aGlzaXNhbmV3bGFiZWwiOiJoZWxsbyJ9fV0=\",\"patchType\":\"JSONPatch\"}}"
# time="2019-03-16T22:19:17Z" level=info msg="Writing response"
# time="2019-03-16T22:19:17Z" level=info msg="adding label to pod"
# time="2019-03-16T22:19:17Z" level=info msg="annotation exists"
# time="2019-03-16T22:19:17Z" level=info msg="excluded due to annotation"
# time="2019-03-16T22:19:17Z" level=info msg="{\"response\":{\"uid\":\"899dfea8-4839-11e9-94c6-08002749fc69\",\"allowed\":true}}"
# time="2019-03-16T22:19:17Z" level=info msg="Writing response"
```

## Credits

Adapted from https://container-solutions.com/some-admission-webhook-basics/ / https://github.com/jasonrichardsmith/mwcexample.
