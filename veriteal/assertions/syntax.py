import json
import argparse
import jsonschema

from typing import List
from .parser import parser
from pathlib import Path


class Assertions:
    mathod_name: str
    assertions: List[str]

    def __init__(self, method_name: str, assertions: List[str]) -> None:
        self.method_name = method_name
        self.assertions = list(map(parser.parse, assertions))

    @classmethod
    def from_json(cls, json_object):
        return cls(
                json_object['method_name'],
                json_object['assertions'],
                )
