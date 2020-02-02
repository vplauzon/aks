# One Ingress Controller for multiple namespaces

This demo how to achieve this using NGinx controller.

We must first install NGinx:

```bash
# Create a namespace for your ingress resources
kubectl create namespace ingress-basic

# Add the official stable repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com/

# Use Helm to deploy an NGINX ingress controller
helm install nginx-ingress stable/nginx-ingress \
    --namespace ingress-basic \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux
```

Find details of this installation in the [AKS online documentation](https://docs.microsoft.com/en-us/azure/aks/ingress-basic#create-an-ingress-controller).

We can validate the Ingress Controller is installed:

```bash
$ kubectl get svc -ningress-basic

NAME                            TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
nginx-ingress-controller        LoadBalancer   10.0.211.140   52.228.111.215   80:30725/TCP,443:30354/TCP   34m
nginx-ingress-default-backend   ClusterIP      10.0.82.178    <none>           80/TCP                       34m
```

We're going to use one of the Azure samples charts to deploy services.  Let's add the charts to Helm Repo:

```bash
helm repo add azure-samples https://azure-samples.github.io/helm-charts/
```

Let's create two namespaces:

```bash
kubectl create ns hello1
kubectl create ns hello2
```

Now let's deploy the same chart twice in the two namespaces.  We'll pass different parameters in order to distinguish the deployment (title is shown in the HTML):

```bash
helm install aks-helloworld azure-samples/aks-helloworld \
    --namespace hello1 \
    --set title="AKS Ingress Demo - 1" \
    --set serviceName="aks-helloworld-one"
helm install aks-helloworld azure-samples/aks-helloworld \
    --namespace hello2 \
    --set title="AKS Ingress Demo - 2" \
    --set serviceName="aks-helloworld-two"
```

We can validate services have been deployed in respective namespaces:

```bash
kubectl get svc -nhello1
kubectl get svc -nhello2
```

We can notice those services do not have external IPs.  We are going to expose them through ingress rules:

```bash
kubectl apply -f ingress1.yaml
kubectl apply -f ingress2.yaml
```

A couple of things to notice about those ingress rules:

* They are deployed in the same namespace as the service they point to
* They use URL-based routing

We can then test those rules.  First, let's find the Public IP of the Ingress Controller.  We actually already seen it when we validated the deployment of the ingress controller:

```bash
$ kubectl get svc -ningress-basic

NAME                            TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
nginx-ingress-controller        LoadBalancer   10.0.211.140   52.228.111.215   80:30725/TCP,443:30354/TCP   34m
nginx-ingress-default-backend   ClusterIP      10.0.82.178    <none>           80/TCP                       34m
```

In our case, the public IP is 52.228.111.215.  We can find that public IP in the managed resource group (i.e. *MC_...* resource group).

If we browse to that IP we should have a `default backend - 404` message at the root.  But if we go at http://52.228.111.215/hello-world-1, we should see `AKS Ingress Demo - 1` while if we go to http://52.228.111.215/hello-world-2, we should see `AKS Ingress Demo - 2`.

We can notice the image link are broken.  This is because both sites point to `/static/...`.  This makes that site a very bad candidate to use URL routing as we did.  But it's simpler to demo...
