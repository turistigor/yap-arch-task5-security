from abc import ABC, abstractmethod
from typing import Any, Iterable

from audit_log_parser.utils import get_key_chain_value


class ISuspiciousChecker(ABC):
    """Абстракция проверки угрозы."""

    @classmethod
    @abstractmethod
    def is_suspicious(cls, record: dict):
        raise NotImplementedError


class ResourceVerbChecker(ISuspiciousChecker):
    """Базовая проверка действия над ресурсом. """

    verb_key = 'verb'
    resource_key = 'objectRef.resource'

    @classmethod
    def is_suspicious(cls, record: dict) -> bool:
        if record.get(cls.verb_key) not in cls.checked_verbs:
            return False

        try:
            resource = get_key_chain_value(record, cls.resource_key)
        except KeyError:
            return False

        return resource in cls.checked_resources


class SecretAccessChecker(ResourceVerbChecker):
    """Проверка просмотра секретов."""

    checked_verbs = set(('get', 'list'))
    checked_resources = set(('secrets',))


class PrivilegedPodCreationChecker(ResourceVerbChecker):
    """Проверка создания привилегированного пода."""

    checked_verbs = set(('create',))
    checked_resources = set(('pods',))

    @classmethod
    def is_suspicious(cls, record: dict) -> bool:
        if not super().is_suspicious(record):
            return False
        
        try:
            containers = get_key_chain_value(record, 'requestObject.spec.containers')
        except KeyError:
            return False

        for container in containers:
            try:
                privileged = get_key_chain_value(container, 'securityContext.privileged')
            except KeyError:
                return False
            
            if privileged is True:
                return True

        return False


class KubectlExecChecker(ResourceVerbChecker):
    """Проверка запуска kubectl exec на чужом поде."""

    verb_key = 'verb'
    resource_key = 'objectRef.subresource'

    checked_verbs = set(('get',))
    checked_resources = set(('exec',))


class FullTextChecker(ISuspiciousChecker):
    """Базовая полнотекстовая проверка записи лога."""

    @classmethod
    def is_suspicious(cls, record: dict) -> bool:
        for value in record.values():
            if cls._is_value_suspicious(value) is True:
                return True
        return False
    
    @classmethod
    def _is_value_suspicious(cls, value: Any) -> bool:
        if isinstance(value, dict):
            if cls.is_suspicious(value) is True:
                return True
        elif isinstance(value, str):  # the order is important
            if cls.wanted_string in value:
                return True
        elif isinstance(value, Iterable):
            for sub_value in value:
                if cls._is_value_suspicious(sub_value) is True:
                    return True

        return False


class AuditPolicyChecker(FullTextChecker):
    """Проверка операций с политикой аудита."""

    wanted_string = 'audit-policy.yaml'


class RoleBindingChecker(ResourceVerbChecker):
    """Проверка привязки ролей."""

    checked_verbs = set(('create',))
    checked_resources = set(('rolebindings','clusterrolebindings'))


checker_set = set((
    SecretAccessChecker,
    PrivilegedPodCreationChecker,
    KubectlExecChecker,
    AuditPolicyChecker,
    RoleBindingChecker,
))
