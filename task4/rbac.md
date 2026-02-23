# Ролевая модель PropDevelopment в кластере K8s

## Роли

| Роль | Область действия | Права роли | Группы пользователей |
| --- | --- | --- | --- |
| NamespaceViewer         | namespace | видят состояние, настройки и ресурсы          | Developers                          |
| NamespaceManager        | namespace | управляют состоянием, настройками и ресурсами | DevOpses                            |
| AppDebugger             | namespace | видят состояние приложений, может отлаживать  | Developers                          |
| AppManager              | namespace | управляет приложениями                        | DevOpses                            |
| SecretsViewer           | namespace | может смотреть секреты                        | Developers, DevOpses, Admins        |
| SecretsManager          | cluster   | полный контроль секретов                      | SecurityOfficer                     |
| SecurityPoliciesManager | cluster   | управление политиками безопасности            | SecurityOfficer                     |
| ClusterAnalyst          | cluster   | мониторинг работы кластера                    | MonitoringEngineer, SecurityOfficer |
| ClusterManager          | cluster   | управление работой кластера                   | Admins                              |

## Группы пользователей

| Группа пользователей | Назначенные RBAC-роли | Обоснование |
| --- | --- | --- |
| Developers         | NamespaceViewer</br> AppDebugger</br> SecretsViewer | Может отлаживать свои приложения, но без возможности изменять инфраструктуру |
| DevOps             | NamespaceManager</br> AppManager</br> SecretsViewer | Управляют приложениями в своих namespace, могут создавать/изменять всё, но секреты только просматривают (создают через CI/CD) |
| SecurityOfficer    | SecurityPoliciesManager</br> SecretsManager</br> ClusterAnalyst | Управляют политиками безопасности и секретами, а также анализируют состояние кластера с точки зрения угроз |
| Admin              | ClusterManager | Управляют всем кластером, но секреты только просматривают, не имеют доступа к данным приложений |
| MonitoringEngineer | ClusterAnalyst | Только собирают метрики и логи, не имеют доступа к управлению или секретам |