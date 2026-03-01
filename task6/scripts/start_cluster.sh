read -p "Delete current minikube (Y/n)?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]
then
    minikube delete --all --purge
fi

minikube start

minikube cp ../audit-policy.yaml /var/lib/minikube/certs/

minikube stop
minikube start \
  --extra-config=apiserver.audit-policy-file=/var/lib/minikube/certs/audit-policy.yaml \
  --extra-config=apiserver.audit-log-path=-
