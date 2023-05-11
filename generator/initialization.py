# TODO: DO NOT * IMPORT
import argparse
from functools import reduce
from constants import *
from methods import method_procedure, bare_call_procedure
from algosdk import abi
from typing import List, Tuple
from algokit_utils import ApplicationSpecification, CallConfig
from algokit_utils import OnCompleteActionName

# TODO: find values to initialize vars
VERIFY_PROCEDURE = "verify"
def verifier_procedure_declaration():
    procedure = procedure_declaration(VERIFY_PROCEDURE)
    procedure += procedure_implementation_beginning(VERIFY_PROCEDURE)
    return procedure

def global_variables_initialization(contract: abi.Contract) -> str:
    (max_arguments, max_transactions, max_applications, max_assets, max_accounts) = max_variables_values(contract.methods)
    max_transactions = 1 # Hardcoded for now. TODO: Handle group transactions
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

    global_variables +=int_variable_declaration(CHOICE_VARIABLE_NAME)
    global_variables +="\n"
    return global_variables

def max_variables_values(methods: List[abi.Method]) -> Tuple[int,int,int,int,int]:
    max_arguments = 0
    max_transactions = 0
    max_accounts = 0
    max_assets = 0
    max_applications = 0
    for method in methods:
        arguments = 1 # 0 is selector.
        transactions = 1 # 0 is current
        accounts = 1 # 0 is sender
        assets = 0
        applications = 1 # 0 is current application
        for argument in method.args:
            match argument.type:
                case abi.UintType() | abi.BoolType() | abi.StringType():
                    arguments += 1
                case abi.ABIReferenceType.ACCOUNT:
                    accounts += 1
                case abi.ABIReferenceType.APPLICATION:
                    applications += 1
                case abi.ABIReferenceType.ASSET:
                    assets += 1
                case abi.ABITransactionType.ANY | abi.ABITransactionType.PAY | abi.ABITransactionType.KEYREG | abi.ABITransactionType.ACFG | abi.ABITransactionType.AXFER | abi.ABITransactionType.AFRZ | abi.ABITransactionType.APPL:
                    transactions += 1
        max_arguments = min(max(max_arguments, arguments), ARGUMENTS_MAX_SIZE)
        max_transactions = min(max(max_transactions, transactions), TRANSACTIONS_MAX_SIZE)
        max_accounts = min(max(max_accounts, accounts), FOREIGNS_MAX_COMBINED_SIZE)
        max_assets = min(max(max_assets, assets), FOREIGNS_MAX_COMBINED_SIZE)
        max_applications = min(max(max_applications, applications), FOREIGNS_MAX_COMBINED_SIZE)
    return (max_arguments, max_transactions, max_applications, max_assets, max_accounts)

def methods_harness(methods: List[str]):
    harness = "while (true){\n"
    harness += havoc_variable(CHOICE_VARIABLE_NAME)
    for index, method_name in enumerate(methods):
        harness += "if (({}) == {}) {{\n".format(CHOICE_VARIABLE_NAME, index)
        harness += procedure_call(method_name)
        harness += "}\n"
    harness += "}\n"
    return harness

def contract_procedure():
    procedure = procedure_declaration(MAIN_CONTRACT_PROCEDURE)
    procedure += procedure_implementation_beginning(MAIN_CONTRACT_PROCEDURE)
    procedure += procedure_implementation_closure()
    return procedure

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('teal_file', type=str, help='Path to teal file.')
    parser.add_argument('application_json', type=str, help='Path to the ABI JSON file.')
    args = parser.parse_args()

    with open(args.application_json, "r") as f:
        application_json = f.read()

    application = ApplicationSpecification.from_json(application_json)
    contract = application.contract
    hints = application.hints
    bare_call_config = application.bare_call_config
    boogie = ""
    methods = []

    boogie += global_variables_initialization(contract)
    for opcode in bare_call_config:
        boogie += bare_call_procedure(opcode)
        methods.append(opcode)

    create_config = CallConfig(2)
    creation_method_name = None

    for method in contract.methods:
        hint = hints[method.get_signature()]
        hint_configs = list(hint.call_config.values())

        try: # Should only be assigned once
            hint_configs.index(create_config)
            creation_method_name = method.name
        except:
            pass

        boogie += method_procedure(method, hint)
        methods.append(method.name)
    if creation_method_name is None:
        creation_method_name = DEFAULT_CONTRACT_CREATION_METHOD
    # TODO: figure out the conctract creation
    boogie += verifier_procedure_declaration()
    boogie += procedure_call(creation_method_name)
    boogie += methods_harness(methods)
    boogie += procedure_implementation_closure()
    boogie += contract_procedure()
    print(boogie)

if __name__ == "__main__":
    main()

