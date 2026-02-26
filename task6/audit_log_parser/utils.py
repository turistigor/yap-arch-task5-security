from typing import Any


def get_key_chain_value(obj: dict, key_chain: str) -> Any:
    if not key_chain:
        return

    for key in key_chain.split('.'):
        value = obj[key]
        obj = value
    return value
