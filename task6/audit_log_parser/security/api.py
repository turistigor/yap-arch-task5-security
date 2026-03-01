import logging as logger

from audit_log_parser.security.checkers import checker_set


def is_suspicious(record: dict | None) -> bool:
    if not record:
        return False

    for checker in checker_set:
        if checker.is_suspicious(record):
            logger.debug(f'Suspicious record: {record}')
            return True
