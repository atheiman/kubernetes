Build a JBoss Docker image locally (cant be pulled from Docker Hub due to licensing). First download a zip release from https://developers.redhat.com/products/eap/download/ using a browser (you'll need a RedHat login, and this must be done through a browser to accept prompts).

Rather than pushing the image to DockerHub, build the image using the Minikube Docker daemon. See https://stackoverflow.com/a/42564211/3343740

```shell
# Build the image using the Dockerfile in this directory.
eval $(minikube docker-env)
docker build -t jboss:dev .

# Create the deployment and service
kubectl apply -f jboss.yaml

# Access the service from your machine
minikube service jboss
```
