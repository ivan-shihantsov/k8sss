# helm + rolling update

install package:<br>
```
git clone <this repo>
cd k8sss/helm-rolling-update

helm install my-release ./foo-bar-app-v1
```


Clean up at the end
```
helm uninstall <release-name> -n <namespace>
```

