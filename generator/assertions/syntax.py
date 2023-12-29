import json
import argparse
import jsonschema

from typing import List, Any
from pathlib import Path

class Term:
    value: Any

    @classmethod
    def from_json(cls, json_object: Any):
        return cls(json_object['value'])

class Operation:
    lhs: Any
    rhs: Any

class Constant(Term):
    value: bool | int
    def __init__(self, value: bool | int):
        self.value = value

class Variable(Term):
    value: str
    def __init__(self, value: str):
        self.value = value

class Formula:
    value: Operation | Constant | Variable

class Assertions:
    mathod_name: str
    preconditions: List[Formula]
    postconditions: List[Formula]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('asserts', type=str, help='Path to the assertions JSON file.')
    args = parser.parse_args()

    with open('schemas/assertions.schema.json', 'r') as file:
       assertions_schema = json.loads(file.read())
    with open(args.asserts, "r") as file:
       assertions = json.loads(file.read())
       jsonschema.validate(
           assertions,
           schema=assertions_schema,
           resolver=jsonschema.RefResolver(
               base_uri=f"{Path(__file__).parent.as_uri()}/schemas/",
               referrer=assertions_schema,
           ),
       )

if __name__ == "__main__":
    main()
