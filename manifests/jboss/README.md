Build a JBoss Docker image locally (cant be pulled from Docker Hub due to licensing). First download a zip release from https://developers.redhat.com/products/eap/download/ using a browser (you'll need a RedHat login, and this must be done through a browser to accept prompts).

Rather than pushing the image to DockerHub, build the image using the Minikube Docker daemon. See https://stackoverflow.com/a/42564211/3343740

```shell
# Build the image using the Dockerfile in this directory. The image includes
# a helloworld Java webapp.
eval $(minikube docker-env)
docker build -t helloworld .

# Create the deployment and service
kubectl apply -f jboss.yaml

# Access the service from your machine
minikube service jboss
```

The `docker build` generates a `.war` package with Maven from the helloworld app. Then it adds JBoss (copies `.zip` from host dir) into an OpenJDK image and `COPY`s the `helloworld.war` into the `$EAP_HOME/standalone/deployments/` directory. When the deployment is launched in Kubernetes, the JBoss default splash screen is served at `/`, but the helloworld app is served at `/helloworld`.

## Ideas

- Deploy two containers in the pod, one is JBoss another is just the war file in a scratch image. Then share the war file over a volume mount to the JBoss `$EAP_HOME/standalone/deployments/` directory. This would allow the app code to update without restarting the JBoss server (maybe this is good, maybe we shouldn't care in a cloud native approach).
-
