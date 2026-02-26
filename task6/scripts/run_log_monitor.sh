mkdir -p ../logs
kubectl logs -f kube-apiserver-minikube -n  kube-system --tail=10 > ../logs/audit.log
