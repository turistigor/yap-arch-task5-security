#!/bin/bash
set -e

NAMESPACE="audit-zone"   # этот namespace уже должен быть размечен PSA restricted

echo "=== Проверка PSA ==="
echo "Тест привилегированного пода:"
if kubectl apply -f ../insecure-manifests/privileged.yaml -n $NAMESPACE 2>&1 | grep -q "violates PodSecurity"; then
  echo "✅ Привилегированный под отклонён (ожидаемо)"
else
  echo "❌ Под не был отклонён"
  exit 1
fi

echo "Тест hostPath:"
if kubectl apply -f ../insecure-manifests/host-path.yaml -n $NAMESPACE 2>&1 | grep -q "violates PodSecurity"; then
  echo "✅ hostPath под отклонён (ожидаемо)"
else
  echo "❌ Под не был отклонён"
  exit 1
fi

echo "Тест root-пользователя:"
if kubectl apply -f ../insecure-manifests/root-user-pod.yaml -n $NAMESPACE 2>&1 | grep -q "violates PodSecurity"; then
  echo "✅ root-под отклонён (ожидаемо)"
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

echo "Все тесты PSA пройдены."