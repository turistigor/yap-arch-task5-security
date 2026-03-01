minikube cp tokens.csv /var/lib/minikube/certs/
minikube start --extra-config=apiserver.token-auth-file=/var/lib/minikube/certs/tokens.csv
