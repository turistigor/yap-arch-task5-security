SUCCESS="[\033[0;32m\u2714\033[0m]"
FAILED="[\033[0;31m\u2718\033[0m]"

main() {
    # Group: admin 
    check_user_cluster_rights "admin-master" "nodes" "replicationcontrollers"
    check_user_cluster_rights "admin-slave" "namespaces" "apps"

    # Group: monitoring-engineer
    check_user_cluster_rights monitoring-engineer-main "nodes/stats" "secrets"
    check_user_cluster_rights monitoring-engineer-replica "events" "networkpolicies"

    # Group: security-officer
    check_user_cluster_rights security-officer-bolik "secrets" "apps"
    check_user_cluster_rights security-officer-lyolik "rolebindings" "storageclasses"

    # Group: landlord-developers
    check_user_namespace_rights landlord-backender "pods/logs"  "landlords" "sales"
    check_user_namespace_rights landlord-frontender "secrets"  "landlords" "sales"

    # Group: landlord-devops
    check_user_namespace_rights landlord-devops-tom "deployments" "landlords" "sales"
    check_user_namespace_rights landlord-devops-tom "cronjobs"  "landlords" "sales"

    # Group: sales-developers
    check_user_namespace_rights sales-backender "pods/logs" "sales" "landlords" 
    check_user_namespace_rights sales-frontender "secrets" "sales" "landlords"

    # Group: sales-devops
    check_user_namespace_rights sales-devops-batman "deployments" "sales" "landlords"
    check_user_namespace_rights sales-devops-robin "cronjobs" "sales" "landlords"
}

check_user_cluster_rights() {
    local user_name="$1"
    local user_token=$(setup_kubectl_context $user_name "tokens.csv") || exit 1

    # k8s available resource: access is expected to be granted
    local available_resource="$2"
    check_access $user_name $user_token $available_resource

    # k8s unavailable resource: access is expected to be forbidden
    local unavailable_resource="$3"
    check_no_access $user_name $user_token $unavailable_resource

    return 0
}


check_user_namespace_rights() {
    local user_name="$1"
    local user_token=$(setup_kubectl_context $user_name "tokens.csv") || exit 1
    local resource="$2"

    # k8s available namespace resource: access is expected to be granted
    local available_ns="$3"
    check_access_ns $user_name $user_token $resource $available_ns

    # k8s unavailable namespace resource: access is expected to be forbidden
    local unavailable_ns="$4"
    check_no_access_ns $user_name $user_token $resource $unavailable_ns

    return 0
}


check_access() {
    local user_name="$1"
    local user_token="$2"
    local resource="$3"

    if kubectl --token="$user_token" auth can-i get $resource >/dev/null 2>&1; then
        echo -e $user_name access test: $SUCCESS
    else
        echo -e $user_name access test: $FAILED
    fi
}


check_no_access() {
    local user_name="$1"
    local user_token="$2"
    local resource="$3"

    if kubectl --token="$user_token" auth can-i get $unavailable_resource >/dev/null 2>&1; then
        echo -e $user_name minimal privileges test: $FAILED
    else
        echo -e $user_name minimal privileges test: $SUCCESS
    fi
}


check_access_ns() {
    local user_name="$1"
    local user_token="$2"
    local resource="$3"
    local ns="$4"

    if kubectl --token="$user_token" auth can-i get $resource -n $ns >/dev/null 2>&1; then
        echo -e $user_name access test: $SUCCESS
    else
        echo -e $user_name access test: $FAILED
    fi
}


check_no_access_ns() {
    local user_name="$1"
    local user_token="$2"
    local resource="$3"
    local ns="$4"

    if kubectl --token="$user_token" auth can-i get $resource -n $ns >/dev/null 2>&1; then
        echo -e $user_name minimal privileges test: $FAILED
    else
        echo -e $user_name minimal privileges test: $SUCCESS
    fi
}


setup_kubectl_context() {
    local user_name="$1"
    local file="${2:-tokens.csv}"

    if [[ ! -f "$file" ]]; then
        echo "Ошибка: Файл '$file' не найден" >&2
        return 1
    fi

    user_token=$(get_token_by_user_name $user_name $file ) || exit 1

    {
        kubectl config set-credentials $user_name --token=$user_token
        kubectl config set-context $user_name-context --user=$user_name --cluster=minikube
        kubectl config use-context $user_name-context
    } &> /dev/null

    echo $user_token
    return 0
}


get_token_by_user_name() {
    local user_name="$1"
    local file="${2:-tokens.csv}"

    if [[ ! -f "$file" ]]; then
        echo "Ошибка: Файл '$file' не найден" >&2
        return 1
    fi

    if [[ -z "$user_name" ]]; then
        echo "Ошибка: Имя пользователя не указано" >&2
        return 1
    fi

    local token
    token=$(grep ",$user_name," "$file" | cut -d, -f1 | head -n1)

    if [[ -z "$token" ]]; then
        echo "Ошибка: Пользователь '$user_name' не найден в файле '$file'" >&2
        return 1
    fi

    echo "$token"
    return 0
}

main "$@"
