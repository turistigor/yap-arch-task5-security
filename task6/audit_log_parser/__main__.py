import os
import logging as logger
from pathlib import Path

from audit_log_parser.parser import collect_suspicious_ids, write_suspicious_records

log_level = os.environ.get('LOG_LEVEL', 'INFO').upper()
logger.basicConfig(level=log_level)

RAW_LOG_PATH = Path('logs/audit.log')
PARSED_LOG_PATH = Path('logs/audit_parsed.json')


def main():
    logger.info('Audit logs parsing stated...')

    suspicious_ids = collect_suspicious_ids(RAW_LOG_PATH)
    logger.info(f'suspicious ids: {suspicious_ids}')

    write_suspicious_records(suspicious_ids, RAW_LOG_PATH, PARSED_LOG_PATH)
    logger.info(f'Parsing results uploaded to {PARSED_LOG_PATH.absolute()}')


if __name__ == '__main__':
    main()
