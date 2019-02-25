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

# Connect to the app
kubectl port-forward app 8888:80
curl http://localhost:8888/

# Rotate the secret in vault
kubectl exec vault -- vault kv put secret/app/db username=app password=rotated updated="$(date)"

# Consul-template will update the app config after a short time
curl http://localhost:8888/
```
