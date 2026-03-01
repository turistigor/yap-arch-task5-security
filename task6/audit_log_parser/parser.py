import json
import logging as logger
from pathlib import Path

from audit_log_parser.security import is_suspicious


def collect_suspicious_ids(raw_log_path: Path) -> set[str]:
    suspicious_ids = set()
    with open(raw_log_path) as audit_file:
        for line in audit_file:
            record = _parse_line(line)
            if is_suspicious(record):
                suspicious_ids.add(record['auditID'])
    return suspicious_ids


def write_suspicious_records(
    suspicious_ids: set[str], raw_log_path: Path, parsed_log_path: Path,
):
    with open(raw_log_path) as audit_file:
        with open (parsed_log_path, 'w') as suspicious_file:
            for line in audit_file:
                if record := _parse_line(line):
                    if record.get('auditID') in suspicious_ids:
                        suspicious_file.write(f'{line}')


def _parse_line(line: str) -> dict | None:
    try:
        return json.loads(line)
    except json.JSONDecodeError as ex:
        logger.debug(f'Incorrect lins: {ex}')
