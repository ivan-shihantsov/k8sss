# Simple Ingress demo


### local app test

first you can run app locally (without k8s):<br>
```
git clone https://github.com/ivan-shihantsov/Py-scripts.git
cd Py-scripts/simple-flask-server
```

and follow README.md <br>
it allows to run and test project in browser<br>
* http://localhost:3001/ - for foo
repeat the same for app `bar` and open on port 3002 <br>


### test in k8s - NodePort service

```
git clone <my-repo>
cd ingress-demo
# run app foo
kubectl apply -f foo/deployment.yaml
kubectl apply -f foo/svc-nodeport.yaml
```

option 1: open inside the cluster<br>
```
kubectl get svc -> CLUSTER-IP
# e.g.: 10.233.108.193
OR
kubectl get pods -o wide -> IP
# e.g.: 10.233.98.87
```
open it in browser from any cluster node:<br>
* `10.233.108.193:3001`
* `10.233.98.87:8001`
repeat the same for `app-bar` and open with CLUSTER-IP (svc) + port 3002<br>

option 2: open outside of cluster - via any node IP + NodePort <br>
node IP: one of my k8s nodes in LAN has IP 192.168.1.15 <br>
NodePort: 32001 <br>
open it in browser from any device on LAN: `192.168.1.15:32001` <br>
repeat the same for `app-bar` and open on port 32002<br>


### test in k8s - ClusterIP + Ingress

in this example you can also check the service via ClusterIP from any cluster node <br>
but now it's interesting to run the ingress

```
# prepare Ingress Controller (nginx)
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.0/deploy/static/provider/baremetal/deploy.yaml

# same as previous example
kubectl apply -f foo/deployment.yaml
kubectl apply -f foo/service.yaml
kubectl apply -f ingress.yaml
```

and open it from the out of the cluster via path (e.g. my machine in local cluster has IP 192.168.1.15): `192.168.1.15/foo` <br>

