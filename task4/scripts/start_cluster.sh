read -p "Delete current minikube (Y/n)?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]
then
    minikube delete --all --purge
fi

minikube start
