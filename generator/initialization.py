import argparse
import subprocess
import json
from pathlib import Path

import jsonschema
from assertions.parser import parser

from constants import *
from tealift import Tealift
from algokit_utils import ApplicationSpecification, CallConfig
from instructions import ParsedInstruction, operation_class
from methods import method_procedure, Method
from typing import List, Tuple, Type

# TODO: This needs to be moved somewhere else
def verifier_procedure_declaration():
    procedure = procedure_declaration(VERIFY_PROCEDURE)
    procedure += procedure_implementation_beginning(VERIFY_PROCEDURE)
    return procedure


# TODO: This needs to be moved somewhere else
# TODO: This is a mock. Needs to be implemented.
def global_variables_initialization(variables: Tuple[int, int, int, int, int]) -> str:
    (max_arguments, max_transactions, max_applications, max_assets, max_accounts) = variables
    max_transactions = 1  # Hardcoded for now. TODO: Handle group transactions
    global_variables = ""
    for transaction in range(max_transactions):
        global_variables += int_variable_declaration(on_completion_variable_name(transaction))
        for index in range(max_arguments):
            global_variables += int_variable_declaration(arguments_variable_name(transaction, index))
        for index in range(max_accounts):
            global_variables += int_variable_declaration(accounts_variable_name(transaction, index))
        for index in range(max_applications):
            global_variables += int_variable_declaration(applications_variable_name(transaction, index))
        for index in range(max_assets):
            global_variables += int_variable_declaration(assets_variable_name(transaction, index))

    global_variables += int_variable_declaration(CHOICE_VARIABLE_NAME)
    global_variables += int_variable_declaration(RETURN_VARIABLE_NAME)
    global_variables += map_int_int_variable_declaration(GLOBAL_SLOTS)
    global_variables += map_int_map_int_int_variable_declaration(LOCAL_SLOTS)
    global_variables += "\n"
    return global_variables


# TODO: This needs to be moved somewhere else
# TODO: This is a mock. Needs to be implemented.
def max_variables_values(methods: List[Method]) -> Tuple[int, int, int, int, int]:
    max_arguments = 0
    max_transactions = 0
    max_accounts = 0
    max_assets = 0
    max_applications = 0
    arguments = 1  # 0 is selector.
    transactions = 1  # 0 is current
    accounts = 1  # 0 is sender
    assets = 0
    applications = 1  # 0 is current application
    max_arguments = min(max(max_arguments, arguments), ARGUMENTS_MAX_SIZE)
    max_transactions = min(max(max_transactions, transactions), TRANSACTIONS_MAX_SIZE)
    max_accounts = min(max(max_accounts, accounts), FOREIGNS_MAX_COMBINED_SIZE)
    max_assets = min(max(max_assets, assets), FOREIGNS_MAX_COMBINED_SIZE)
    max_applications = min(max(max_applications, applications), FOREIGNS_MAX_COMBINED_SIZE)
    return max_arguments, max_transactions, max_applications, max_assets, max_accounts


# TODO: This needs to be moved somewhere else
#def max_variables_values(methods: List[abi.Method]) -> Tuple[int, int, int, int, int]:
#    max_arguments = 0
#    max_transactions = 0
#    max_accounts = 0
#    max_assets = 0
#    max_applications = 0
#    for method in methods:
#        arguments = 1  # 0 is selector.
#        transactions = 1  # 0 is current
#        accounts = 1  # 0 is sender
#        assets = 0
#        applications = 1  # 0 is current application
#        for argument in method.args:
#            match argument.type:
#                case abi.UintType() | abi.BoolType() | abi.StringType():
#                    arguments += 1
#                case abi.ABIReferenceType.ACCOUNT:
#                    accounts += 1
#                case abi.ABIReferenceType.APPLICATION:
#                    applications += 1
#                case abi.ABIReferenceType.ASSET:
#                    assets += 1
#                case abi.ABITransactionType.ANY | \
#                        abi.ABITransactionType.PAY | \
#                        abi.ABITransactionType.KEYREG | \
#                        abi.ABITransactionType.ACFG | \
#                        abi.ABITransactionType.AXFER | \
#                        abi.ABITransactionType.AFRZ | \
#                        abi.ABITransactionType.APPL:
#                    transactions += 1
#
#        max_arguments = min(max(max_arguments, arguments), ARGUMENTS_MAX_SIZE)
#        max_transactions = min(max(max_transactions, transactions), TRANSACTIONS_MAX_SIZE)
#        max_accounts = min(max(max_accounts, accounts), FOREIGNS_MAX_COMBINED_SIZE)
#        max_assets = min(max(max_assets, assets), FOREIGNS_MAX_COMBINED_SIZE)
#        max_applications = min(max(max_applications, applications), FOREIGNS_MAX_COMBINED_SIZE)
#    return max_arguments, max_transactions, max_applications, max_assets, max_accounts

def assert_assertions(method_name, assertions):
    assertions_string = ""
    try:
        conditions = assertions[method_name]
        for condition in conditions:
            assertions_string += f"assert {parser.parse(condition)};\n"
    except KeyError:
        pass
    return assertions

# TODO: This needs to be moved somewhere else
def methods_harness(methods: List[str], assertions_json):
    harness = "while (true){\n"
    harness += havoc_variable(CHOICE_VARIABLE_NAME)
    for index, method_name in enumerate(methods):
        harness += "if (({}) == {}) {{\n".format(CHOICE_VARIABLE_NAME, index)
        harness += procedure_call(method_name)
        harness += assert_assertions(method_name,  assertions_json)
        harness += "}\n"
    harness += "}\n"
    return harness


# TODO: This needs to be moved somewhere else
def main_contract_procedure(tealift: Tealift):
    var_names = set()
    phi_values = tealift.phis_values()
    main_procedure = ""

    for block_index, block in enumerate(tealift.basic_blocks):
        main_procedure += label_declaration(block_index)
        for phi_index, phi in enumerate(block.phis):  # Assign value to the phi
            phi_var_name = phi_variable_name(block_index, phi_index)
            phi_val_name = phi_value_name(block_index, phi_index)
            var_names.add(phi_var_name)
            var_names.add(phi_val_name)
            main_procedure += variable_assigment(phi_var_name, phi_val_name)
            if (block_index, -(phi_index + 1)) in phi_values:  # Checks if value of another phi
                values = phi_values[(block_index, -(phi_index + 1))]
                for value in values:
                    other_phi_block_index, other_phi_index = value
                    main_procedure += variable_assigment(phi_value_name(other_phi_block_index, other_phi_index),
                                                         phi_var_name)

        for instruction_index, instruction in enumerate(block.instructions):
            try:
                c: Type[ParsedInstruction]
                c = operation_class[instruction.operation]
                parsed_instruction: ParsedInstruction = c(instruction, instruction_index, block, block_index)
                parsed_instruction_boogie = parsed_instruction.to_boogie()
            except KeyError:
                print("Operation not found")
                continue
            if parsed_instruction.returns_value():
                var_name = local_variable_name(instruction_index)
                var_names.add(var_name)
                parsed_instruction_boogie = variable_assigment(var_name, parsed_instruction_boogie)

            main_procedure += parsed_instruction_boogie
            if (block_index, instruction_index) in phi_values:  # Check if value of a phi
                values = phi_values.get((block_index, instruction_index), [])
                for value in values:
                    phi_block_index, phi_index = value
                    phi_val_name = phi_value_name(phi_block_index, phi_index)
                    main_procedure += variable_assigment(phi_val_name, var_name)

    procedure_variables_declaration = ""
    for slot in range(SCRATCH_SLOTS):
        procedure_variables_declaration += int_variable_declaration(scratch_slot_variable_name(slot))
    for var_name in var_names:
        procedure_variables_declaration += int_variable_declaration(var_name)

    full_procedure = procedure_declaration(MAIN_CONTRACT_PROCEDURE_NAME)
    full_procedure += procedure_implementation_beginning(MAIN_CONTRACT_PROCEDURE_NAME)
    full_procedure += procedure_variables_declaration
    full_procedure += main_procedure
    full_procedure += EXIT_LABEL_BLOCK
    full_procedure += procedure_implementation_closure()

    return full_procedure


def run_tealift(teal_file_path):
    with open('jsons/tealift.json', 'w+') as tealift_json:
        subprocess.run(["node", "../tealift/src/json.js", teal_file_path], stdout=tealift_json)
        json_file = tealift_json.seek(0)  # move file handle to begging of the file
        return Tealift.from_json(json_file)


# TODO: This needs to be moved somewhere else
def get_creation_method_name(contract, hints):
    # Create method calls functions with the application.json
    creation_method_name = None
    create_config = CallConfig(2)
    for method in contract.methods:
        hint = hints[method.get_signature()]
        hint_configs = list(hint.call_config.values())

        try:  # Assignment should only happen once
            hint_configs.index(create_config)
            creation_method_name = method.name
        except:
            pass
    # If no constructor provider, no_op bare call is the default constructor
    if creation_method_name is None:
        creation_method_name = NO_OP
    return creation_method_name


# TODO: This needs to be moved somewhere else
def methods_procedures(methods: List[Method]):
    procedures = ""
    # Create method calls functions with the application.json
    for method in methods:
        procedures += method_procedure(method)
    return procedures


#def methods_procedures(methods: List[abi.Method], hints):
#    procedures = ""
#    # Create method calls functions with the application.json
#    for method in methods:
#        hint = hints[method.get_signature()]
#        procedures += method_procedure(method, hint)
#    return procedures


# TODO: This needs to be moved somewhere else
def get_methods_names(contract, bare_call_config):
    methods = []
    for opcode in bare_call_config:
        methods.append(opcode)
    for method in contract.methods:
        methods.append(method.name)
    return methods


## TODO: This needs to be moved somewhere else
#def bare_call_procedures(bare_call_config):
#    procedures = ""
#    for opcode in bare_call_config:
#        procedures += bare_call_procedure(opcode)
#    return procedures


# TODO: This needs to be moved somewhere else
def verify_procedure(creation_method_name, methods, assertions):
    procedure = verifier_procedure_declaration()
    procedure += procedure_call(creation_method_name)
    procedure += assert_assertions(creation_method_name, assertions)
    procedure += methods_harness(methods, assertions)
    procedure += procedure_implementation_closure()
    return procedure


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('teal_file', type=str, help='Path to teal file.')
    parser.add_argument('application_json', type=str, help='Path to the ABI JSON file.')
    parser.add_argument('asserts', type=str, help='Path to the assertions JSON file.')
    parser.add_argument('-c', '--custom', help='Flag indicating that the JSON uses the custom VeriTeal schema.'
                                               'Schema.', action="store_true")
    args = parser.parse_args()

    with open('jsons/tealift.json', 'r') as file:
        tealift = Tealift.from_json(file.read())
    with open(args.application_json, "r") as file:
        application_json = file.read()
    with open('schemas/application.schema.json', 'r') as file:
        application_schema = json.loads(file.read())
    with open('schemas/assertions.schema.json', 'r') as file:
        assertions_schema = json.loads(file.read())
    with open(args.asserts, "r") as file:
        assertions = json.loads(file.read())
        jsonschema.validate(
            assertions,
            schema=assertions_schema,
        )

    if not args.custom:
        application = ApplicationSpecification.from_json(application_json)
        contract = application.contract
        hints = application.hints
        bare_call_config = application.bare_call_config

        methods = list(map(lambda method: Method.from_abi_method(method, hints[method.get_signature()]), application.contract.methods))
        methods += list(
            map(
                lambda tuple: Method.from_bare_call(
                    tuple[0],
                    tuple[1]
                ),
                application.bare_call_config.items()
            )
        )

        creation_method_name = get_creation_method_name(contract, hints)
        methods_names = get_methods_names(contract, bare_call_config)
    else:

        application = json.loads(application_json)
        jsonschema.validate(
            application,
            schema=application_schema,
            resolver=jsonschema.RefResolver(
                base_uri=f"{Path(__file__).parent.as_uri()}/schemas/",
                referrer=application_schema,
            ),
        )
        methods = list(map(Method.from_dict, application["methods"]))
        creation_method_name = DEFAULT_CONTRACT_CREATION_METHOD
        methods_names = list(map(lambda method: method.name, methods))

    max_values = max_variables_values(methods)
    # Initialize global variables
    boogie = global_variables_initialization(max_values)
    # Add functions and axioms
    boogie += functions_declarations()
    # Define methods procedures
    boogie += methods_procedures(methods)
    # Create method harness
    boogie += verify_procedure(creation_method_name, methods_names, assertions)
    # Translate main contract with tealift
    boogie += main_contract_procedure(tealift)

    with open("artifacts/output.bpl", "w") as output_file:
        output_file.write(boogie)
    # Run Corral
    subprocess.run(["corral", "artifacts/output.bpl", "/main:verify_"])


if __name__ == "__main__":
    main()
