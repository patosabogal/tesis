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

#def main():
#    arg_parser = argparse.ArgumentParser()
#    arg_parser.add_argument('asserts', type=str, help='Path to the assertions JSON file.')
#    args = arg_parser.parse_args()
#
#    with open('schemas/assertions.schema.json', 'r') as file:
#       assertions_schema = json.loads(file.read())
#    with open(args.asserts, "r") as file:
#       assertions = json.loads(file.read())
#       jsonschema.validate(
#           assertions,
#           schema=assertions_schema,
#           resolver=jsonschema.RefResolver(
#               base_uri=f"{Path(__file__).parent.as_uri()}/schemas/",
#               referrer=assertions_schema,
#           ),
#       )
#    for assertion in assertions:
#
#
#if __name__ == "__main__":
#    main()
