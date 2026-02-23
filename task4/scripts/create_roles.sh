echo "📁 Создаём namespaces..."
kubectl apply -f ../kubernetes/namespaces/

echo "📦 Применяем роли Sales Services..."
kubectl apply -f ../kubernetes/roles/sales/

echo "📦 Применяем роли landlord Services..."
kubectl apply -f ../kubernetes/roles/landlords/

echo "🌐 Применяем кластерные роли..."
kubectl apply -f ../kubernetes/roles/cluster/

echo "✅ Готово!"
