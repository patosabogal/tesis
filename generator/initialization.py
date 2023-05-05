# TODO: DO NOT * IMPORT
import argparse
from constants import *
from methods import method_procedure, bare_call_procedures
from algosdk import abi
from typing import List, Tuple
from algokit_utils import ApplicationSpecification
from algokit_utils import OnCompleteActionName

# TODO: find values to initialize vars
# TODO: support group transactions
VERIFY_PROCEDURE = "verify"
def verifier_procedure_declaration():
    procedure = PROCEDURE_DECLARATION.format(VERIFY_PROCEDURE)
    procedure += PROCEDURE_IMPLEMENTATION_BEGINNING.format(VERIFY_PROCEDURE)
    return procedure

def verifier_procedure_closure():
    procedure = PROCEDURE_IMPLEMENTATION_CLOSURE
    return procedure


def global_variables_initialization(contract: abi.Contract) -> str:
    (max_arguments, max_transactions, max_applications, max_assets, max_accounts) = max_variables_values(contract.methods)
    max_transactions = 1 # Hardcoded. Handle group transactions
    global_variables = ""
    for transaction in range(max_transactions):
        global_variables += INT_VARIABLE_DECLARATION.format(ON_COMPLETION_VARIABLE_NAME.format(transaction))
        for index in range(max_arguments):
            global_variables += INT_VARIABLE_DECLARATION.format(ARGUMENTS_VARIABLE_NAME.format(transaction, index))
        for index in range(max_accounts):
            global_variables += INT_VARIABLE_DECLARATION.format(ACCOUNTS_VARIABLE_NAME.format(transaction, index))
        for index in range(max_applications):
            global_variables += INT_VARIABLE_DECLARATION.format(APPLICATIONS_VARIABLE_NAME.format(transaction, index))
        for index in range(max_assets):
            global_variables += INT_VARIABLE_DECLARATION.format(ASSETS_VARIABLE_NAME.format(transaction, index))

    return global_variables

def max_variables_values(methods: List[abi.Method]) -> Tuple[int,int,int,int,int]:
    max_arguments = 0
    max_transactions = 0
    max_accounts = 0
    max_assets = 0
    max_applications = 0
    for method in methods:
        arguments = 1 # 0 is selector. TODO: handle bare
        transactions = 1 # 0 is current
        accounts = 1 # 0 is sender
        assets = 0
        applications = 1 # 0 is current application#
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
    boogie += global_variables_initialization(contract)

    print('hints')
    for hint, value in hints.items():
        print(hint, list(value.call_config.values()))
    boogie += bare_call_procedures(bare_call_config)
    for method in contract.methods:
        boogie += method_procedure(method)
    # TODO: figure out the conctract call
    boogie += verifier_procedure_declaration()
    boogie += verifier_procedure_closure()
    print(boogie)
    #for method in contract.methods:
    #    #TODO: Handle creation and bare calls

if __name__ == "__main__":
    main()

