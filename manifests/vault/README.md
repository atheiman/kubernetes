```shell
# Create vault service
kubectl apply -f vault.yaml

# (Optional) Expose Vault service with a LoadBalancer and connect from workstation using cli
kubectl expose deployment frontend --type=LoadBalancer --name=vault-lb --labels=app=guestbook,tier=frontend
export VAULT_ADDR="http://$(kubectl get svc vault-lb -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
export VAULT_TOKEN=root-token
vault secrets list

# Create app that renders a secret from Vault
kubectl apply -f app.yaml

# Connect to the app (Minikube)
minikube service
# Connect to the app (Other)
kubectl port-forward app 8888:80
curl http://localhost:8888/

# Check the app (nginx) pids from the consul-template container
kubectl exec config-file-app -c consul-template -- /bin/sh -c 'ps -ef | grep nginx | grep -v grep'
kubectl exec env-vars-app -c app -- /bin/sh -c 'ps -ef | grep -v "ps -ef"'

# Rotate the secret in vault
kubectl exec vault -- vault kv put secret/app/db username=app password=rotated updated="$(date)"

# Consul-template will update the app config after a short time, send another http
# request to the app and the app config (the html file) should be updated!
#
# Also, you can see the nginx worker process is new because consul-template sent a SIGHUP
# to nginx when the app config was updated. This is possible using the
# PodShareProcessNamespace feature.
```
