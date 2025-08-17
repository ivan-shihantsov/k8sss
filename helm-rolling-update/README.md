# helm chart + rolling update

install package:<br>
```
git clone <this repo>
cd k8sss/helm-rolling-update

helm install foo ./foo-bar-app-v1
helm install bar ./foo-bar-app-v1 --set container.image='hostick/bar:v1' --set svcPort=3002 --set svcNodePort=32002
```

Check the result and open in browser<br>
```
kubectl get pods -o wide
kubectl get svc -o wide
```

Check the result and open in browser<br>
```
helm upgrade foo ./foo-bar-app-v2

# check the pods update in the live
kubectl get pods -o wide

# show the helm revisions
helm list
```

Try to rollback the update<br>
```
helm rollback foo 1
```

Clean up at the end<br>
```
helm uninstall foo ./foo-bar-app-v1
helm uninstall bar ./foo-bar-app-v1
```

