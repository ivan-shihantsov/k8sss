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

```
git clone <my-repo>
cd ingress-demo
kubectl apply -f foo/deployment.yaml
kubectl apply -f foo/service.yaml
kubectl apply -f bar/deployment.yaml
kubectl apply -f bar/service.yaml
```

in this example you can also check the service via ClusterIP from any cluster node <br>
but now it's interesting to run the ingress<br>

prepare Ingress Controller (nginx)<br>
```
kubectl create namespace ingress-nginx

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.13.1/deploy/static/provider/cloud/deploy.yaml
OR
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --namespace ingress-nginx --set controller.publishService.enabled=true

# and start our Ingress Object
kubectl apply -f ingress.yaml
```

now do the following and get CLUSTER-IP from the `ingress-nginx-controller`:<br>
```
# kubectl get svc -n ingress-nginx
NAME                                               TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
nginx-ingress-ingress-nginx-controller             LoadBalancer   10.233.62.218   <pending>     80:31849/TCP,443:31409/TCP   29m
```

and open it in browser:<br>
* from any cluster node: `10.233.62.218/foo` and `10.233.62.218/bar` <br>
* from the out of the cluster (via any node IP + Ingress NodePort): `http://192.168.1.15:31849/foo` or `https://192.168.1.15:31409/foo` <br>


### Add a dashboard

```
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm repo update
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```

now you can open it within cluster via CLUSTER-IP:PORT (10.233.59.85:8000)
```
# kubectl get svc kubernetes-dashboard-kong-proxy -n kubernetes-dashboard
NAME                       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
kubernetes-dashboard-web   ClusterIP   10.233.59.85   <none>        8000/TCP   5m41s
```

or change the service type to NodePort (port: 31031) - `kubectl edit svc kubernetes-dashboard-kong-proxy -n kubernetes-dashboard` <br>
and open open outside of cluster - via any node IP + dashboard NodePort: 192.168.1.15:31031 <br>

also create the Login Token
```
kubectl apply -f svc-acc-dashboard-login.yaml

# get the token to login
kubectl -n kubernetes-dashboard create token admin-user

# also you can do it like this
kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath="{.data.token}" | base64 -d
```

