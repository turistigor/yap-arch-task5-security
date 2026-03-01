#!/bin/bash

read -p "Delete current minikube (Y/n)?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]
then
    minikube delete --all --purge
fi

minikube start

kubectl apply -f audit-zone.yaml
kubectl config set-context --current --namespace=audit-zone
