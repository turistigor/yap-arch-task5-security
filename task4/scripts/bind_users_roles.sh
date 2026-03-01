echo "📦 Связываем роли и пользователей в Sales Services..."
kubectl apply -f ../kubernetes/roles_bindings/sales/

echo "📦 Связываем роли и пользователей в landlord Services..."
kubectl apply -f ../kubernetes/roles_bindings/landlords/

echo "🌐 Связываем роли и пользователей в кластере..."
kubectl apply -f ../kubernetes/roles_bindings/cluster/

echo "✅ Готово!"
