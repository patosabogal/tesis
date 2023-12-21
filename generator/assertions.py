import json
import argparse
import jsonschema
from pathlib import Path

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
