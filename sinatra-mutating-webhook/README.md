# Mutating Webhook Admission Controller Example

This project shows that mutating webhook admission controllers can be written in any language. I chose to create this in Ruby using Sinatra because I am very comfortable with it. I found that the api will receive POST requests like:

```
POST /mutating-pods?timeout=30s HTTP/2.0
Host: mutating-admission-webhook.mutating-admission-webhook.svc:443
Accept: application/json, */*
Accept-Encoding: gzip
Content-Length: 1736
Content-Type: application/json
User-Agent: kube-apiserver-admission

{
  "kind":"AdmissionReview",
  "apiVersion":"admission.k8s.io/v1beta1",
  "request":{
    "uid":"04fd0545-483e-11e9-94c6-08002749fc69",
    "kind":{
      "group":"",
      "version":"v1",
      "kind":"Pod"
    },
    "resource":{
      "group":"",
      "version":"v1",
      "resource":"pods"
    },
    "namespace":"mwc-test",
    "operation":"CREATE",
    "userInfo":{
      "username":"minikube-user",
      "groups":[
        "system:masters",
        "system:authenticated"
      ]
    },
    "object":{
      "metadata":{
        "name":"excluded",
        "namespace":"mwc-test",
        "creationTimestamp":null,
        "annotations":{
          "kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"v1\",\"kind\":\"Pod\",\"metadata\":{\"annotations\":{\"mutating-webhook.example.com/exclude\":\"true\"},\"name\":\"excluded\",\"namespace\":\"mwc-test\"},\"spec\":{\"containers\":[{\"image\":\"k8s.gcr.io/pause\",\"name\":\"app\"}]}}\n",
          "mutating-webhook.example.com/exclude":"true"
        }
      },
      "spec":{
        "volumes":[
          {
            "name":"default-token-vks5v",
            "secret":{
              "secretName":"default-token-vks5v"
            }
          }
        ],
        "containers":[
        // Object spec continues
      },
      "status":{}
    },
    "oldObject":null,
    "dryRun":false
  }
}
```

The api should respond to the kube-apiserver with a response like:

```
{
  "response":{
    "uid":"04f7bcca-483e-11e9-94c6-08002749fc69",
    "allowed":true,
    "patch":"W3sib3AiOiJhZGQiLCJwYXRoIjoiL21ldGFkYXRhL2xhYmVscyIsICJ2YWx1ZSI6eyJ0aGlzaXNhbmV3bGFiZWwiOiJoZWxsbyJ9fV0=",
    "patchType":"JSONPatch"
  }
}
```

`patch` and `patchType` can be omitted to not make any changes to the object.

## Try it!

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
