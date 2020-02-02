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

```bash
helm repo add azure-samples https://azure-samples.github.io/helm-charts/
```

kubectl create ns hello1
kubectl create ns hello2

helm install aks-helloworld azure-samples/aks-helloworld \
    --namespace hello1 \
    --set title="AKS Ingress Demo - 1" \
    --set serviceName="aks-helloworld-one"
helm install aks-helloworld azure-samples/aks-helloworld \
    --namespace hello2 \
    --set title="AKS Ingress Demo - 2" \
    --set serviceName="aks-helloworld-two"

kubectl get svc -nhello1
kubectl get svc -nhello2

(No external IP)

kubectl apply -f ingress1.yaml
kubectl apply -f ingress2.yaml
