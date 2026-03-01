read -p "Delete current minikube (Y/n)?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]
then
    minikube delete --all --purge
fi

minikube start --cni=calico
kubectl create namespace task5-network-policy
kubectl config set-context --current --namespace=task5-network-policy

sleep 5

kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80

kubectl apply -f ../network_policies/front_back.yaml
kubectl apply -f ../network_policies/front_back_admin.yaml
