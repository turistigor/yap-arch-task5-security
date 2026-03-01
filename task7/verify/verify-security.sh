#!/bin/bash
set -e

NAMESPACE="gatekeeper-audit-zone"

echo "=== Проверка Gatekeeper ==="
echo "Тест привилегированного пода:"
if kubectl apply -f ../insecure-manifests/privileged.yaml -n $NAMESPACE 2>&1 | grep -q "\"validation.gatekeeper.sh\" denied"; then
  echo "✅ Привилегированный под отклонён Gatekeeper'ом"
else
  echo "❌ Под не был отклонён"
  exit 1
fi

echo "Тест hostPath:"
if kubectl apply -f ../insecure-manifests/host-path.yaml -n $NAMESPACE 2>&1 | grep -q "\"validation.gatekeeper.sh\" denied"; then
  echo "✅ hostPath под отклонён Gatekeeper'ом"
else
  echo "❌ Под не был отклонён"
  exit 1
fi

echo "Тест root-пользователя (без runAsNonRoot и readOnlyRootFilesystem):"
if kubectl apply -f ../insecure-manifests/root-user-pod.yaml -n $NAMESPACE 2>&1 | grep -q "\"validation.gatekeeper.sh\" denied"; then
  echo "✅ root-под отклонён Gatekeeper'ом"
else
  echo "❌ Под не был отклонён"
  exit 1
fi

echo "Применение безопасных подов:"
kubectl apply -f ../secure-manifests/ -n $NAMESPACE
sleep 15
for pod in unprivileged-pod emptydir-pod nonroot-pod; do
  if kubectl get pod -n $NAMESPACE $pod -o jsonpath='{.status.phase}' | grep -q "Running"; then
    echo "✅ $pod успешно запущен"
  else
    echo "❌ $pod не запущен"
    kubectl describe pod -n $NAMESPACE $pod
    exit 1
  fi
done

echo "Все тесты Gatekeeper пройдены."