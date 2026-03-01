# Аудит и обеспечение соответствия политике безопасности контейнеров

- Запуск кластера и первичная настройка
    ```bash
    cd task7
    ./start_cluster.sh
    ```
- Проверка создания подов удовлетворяющих требованиям PSA и отказа для не удовлетворяющих:
    ```bash
    cd verify
    ./verify-admission.sh
    ```

- Установка Gatekeeper
    ```bash
    helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
    helm install gatekeeper/gatekeeper \
        --name-template gatekeeper \
        --namespace gatekeeper-system \
        --create-namespace \
        --version 3.18.0

    # Проверка успешности с ожиданием
    kubectl wait --for=condition=ready pod -l gatekeeper.sh/system=yes -n gatekeeper-system --timeout=60s
    ```

- Применяем шаблоны и ограничения
    ```bash
    cd task7
    kubectl apply -f gatekeeper/constraint-templates/

    # Проверка
    kubectl get constrainttemplates
    # NAME              AGE
    # k8shostpath       8s
    # k8sprivileged     50m
    # k8srunasnonroot   7s

    kubectl apply -f gatekeeper/constraints/
    # Проверка
    kubectl get constraints
    # NAME                                                          ENFORCEMENT-ACTION TOTAL-VIOLATIONS
    # k8shostpath.constraints.gatekeeper.sh/no-hostpath             deny               1
    # k8sprivileged.constraints.gatekeeper.sh/no-privileged         deny               1
    # k8srunasnonroot.constraints.gatekeeper.sh/must-run-as-nonroot deny               1
    ```

- Подготавливаем тестовую среду для проверке gatekeeper
    ```bash
    kubectl create ns gatekeeper-audit-zone
    kubectl config set-context --current --namespace=gatekeeper-audit-zone
    ```

- Проверка создания подов удовлетворяющих требованиям PSA и отказа для не удовлетворяющих:
    ```bash
    cd verify
    ./verify-security.sh
    ```
