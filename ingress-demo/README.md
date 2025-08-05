# Simple Ingress demo

### local app test

first you can run app locally (without k8s):<br>
install nodejs - https://nodejs.org/en/download <br>
```
npm install express

git clone <my-repo>
cd ingress-demo/app_foo
npm start
```

and open in browser: localhost:3001 <br>
repeat the same for app `bar` and open on port 3002 <br>

### test in k8s - NodePort service

```
git clone <my-repo>
cd ingress-demo
kubectl apply -f kube/foo/deployment.yaml
kubectl apply -f kube/foo/svc-nodeport.yaml
```

now you can open it via ClusterIP: <br>
```
kubectl get pods -o wide
# get one of them, e.g.: 10.233.108.193
```

and open it in browser from any cluster node: `10.233.108.193:3001` (but not `localhost:3001`) <br>
or open it from the out of the cluster via node IP (e.g. my machine in local cluster has IP 192.168.1.15) and NodePort: `192.168.1.15:32001` <br>
repeat the same for app `bar` and open on ports 3002 (with ClusterIP) or 32002 (for NodePort)<br>

### test in k8s - ClusterIP + Ingress

in this example you can also check the service via ClusterIP from any cluster node <br>
but now it's interesting to run the ingress

```
# same as previous example
kubectl apply -f kube/foo/deployment.yaml
kubectl apply -f kube/foo/service.yaml
kubectl apply -f kube/ingress.yaml
```

and open it from the out of the cluster via path (e.g. my machine in local cluster has IP 192.168.1.15): `192.168.1.15/foo` <br>

