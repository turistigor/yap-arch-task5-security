BACK_END="back-end-api"
FRONT_END="front-end"
ADMIN_BACK_END="admin-back-end-api"
ADMIN_FRONT_END="admin-front-end"

main() {
    local tested_role=$FRONT_END
    echo $tested_role "access tests:"
    check_access "role=$tested_role" $BACK_END"-app" "allowed"
    check_access "role=$tested_role" $ADMIN_BACK_END"-app" "denied"
    check_access "role=$tested_role" $ADMIN_FRONT_END"-app" "denied"

    tested_role=$BACK_END
    echo $tested_role "access tests:"
    check_access "role=$tested_role" $FRONT_END"-app" "allowed"
    check_access "role=$tested_role" $ADMIN_BACK_END"-app" "denied"
    check_access "role=$tested_role" $ADMIN_FRONT_END"-app" "denied"

    tested_role=$ADMIN_BACK_END
    echo $tested_role "access tests:"
    check_access "role=$tested_role" $ADMIN_FRONT_END"-app" "allowed"
    check_access "role=$tested_role" $BACK_END"-app" "denied"
    check_access "role=$tested_role" $FRONT_END"-app" "denied"

    tested_role=$ADMIN_FRONT_END
    echo $tested_role "access tests:"
    check_access "role=$tested_role" $ADMIN_BACK_END"-app" "allowed"
    check_access "role=$tested_role" $BACK_END"-app" "denied"
    check_access "role=$tested_role" $FRONT_END"-app" "denied"
}

check_access() {
    local pod_name=test-$RANDOM
    local labels="$1"
    local target_service="$2"
    local expected_result="$3"

    local output=$(kubectl run "$pod_name" \
            --image=alpine \
            --labels="$labels" \
            --restart=Never \
            --attach \
            --command -- /bin/sh -c "wget -qO- --timeout=1 http://$target_service" 2>&1)
    
    kubectl delete pod "$pod_name" --grace-period=0 --force &>/dev/null

    if [ $expected_result = "allowed" ]; then
        if echo "$output" | grep -q "Welcome to nginx"; then
            echo "✅ PASS: $labels → $target_service доступ разрешён"
        else
            echo "❌ FAIL: $labels → $target_service доступ запрещён"
        fi
    else
        if echo "$output" | grep -q "wget: download timed"; then
            echo "✅ PASS: $labels → $target_service доступ запрещён"
        else
            echo "❌ FAIL: $labels → $target_service доступ разрешён"
        fi
    fi
}

main "$@"
