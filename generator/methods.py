# TODO: DO NOT * IMPORT
from constants import *
from sys import argv
from algosdk import abi
from Crypto.Hash import keccak
from algokit_utils import MethodConfigDict


def method_initialization(method: abi.Method):
    procedure_initialization = PROCEDURE_DECLARATION.format(method.name)
    procedure_initialization += PROCEDURE_IMPLEMENTATION_BEGINNING.format(method.name)
    return procedure_initialization

def method_closure():
    procedure_closure = CONTRACT_CALL
    procedure_closure += PROCEDURE_IMPLEMENTATION_CLOSURE
    return procedure_closure

def bytes_to_int(bytes_string: bytes):
    k = keccak.new(digest_bits=256)
    k.update(bytes_string)
    hex = k.hexdigest()
    return int(hex, 16)

def method_variables_declaration(method: abi.Method):
    procedure_variables = INT_VARIABLE_DECLARATION.format(CURRENT_TRANSACTION_INDEX, SELECTOR_INDEX)
    arguments_index = 1 # 0 is method signature
    accounts_index = 1 # 0 is sender
    applications_index = 1 # 0 is current_application_id
    assets_index = 0 # starts empyt unless trnasaction is an asset_transfer, which is not
    #transactions_group_offset = 1 # 0 is current transaction

    for arg in method.args:
        match arg.type:
            case abi.UintType() | abi.BoolType() | abi.StringType():
                procedure_variables += INT_VARIABLE_DECLARATION.format(ARGUMENTS_VARIABLE_NAME.format(CURRENT_TRANSACTION_INDEX, arguments_index))
                arguments_index += 1
            case abi.ABIReferenceType.ACCOUNT:
                procedure_variables += INT_VARIABLE_DECLARATION.format(ACCOUNTS_VARIABLE_NAME.format(CURRENT_TRANSACTION_INDEX, accounts_index))
                accounts_index += 1
            case abi.ABIReferenceType.APPLICATION:
                procedure_variables += INT_VARIABLE_DECLARATION.format(CURRENT_TRANSACTION_INDEX, APPLICATIONS_VARIABLE_NAME.format(applications_index))
                applications_index += 1
            case abi.ABIReferenceType.ASSET:
                procedure_variables += INT_VARIABLE_DECLARATION.format(CURRENT_TRANSACTION_INDEX, ASSETS_VARIABLE_NAME.format(assets_index))
                assets_index += 1
            #case abi.ABITransactionType.ANY | abi.ABITransactionType.PAY | abi.ABITransactionType.KEYREG | abi.ABITransactionType.ACFG | abi.ABITransactionType.AXFER | abi.ABITransactionType.AFRZ | abi.ABITransactionType.APPL:
            #    procedure_variables += INT_VARIABLE_DECLARATION.format(TRANSACTION_VARIABLE_NAME.format(transactions_group_offset))
            #    transactions_group_offset += 1
            #case _:
            #    Exception('Invalid type.')

    return procedure_variables

def method_variables_assigment(method: abi.Method):
    procedure_variables = VARIABLE_ASSIGMENT.format(ARGUMENTS_VARIABLE_NAME.format(CURRENT_TRANSACTION_INDEX, SELECTOR_INDEX), bytes_to_int(method.get_selector()))
    arguments_index = 1 # 0 is method signature
    accounts_index = 1 # 0 is sender
    applications_index = 1 # 0 is current_application_id
    assets_index = 0 # starts empyt unless trnasaction is an asset_transfer, which is not
    #transactions_group_offset = 1 # 0 is current transaction

    for arg in method.args:
        match arg.type:
            case abi.UintType() | abi.BoolType() | abi.StringType():
                procedure_variables += HAVOC_VARIABLE.format(ARGUMENTS_VARIABLE_NAME.format(CURRENT_TRANSACTION_INDEX, arguments_index))
                arguments_index += 1
            case abi.ABIReferenceType.ACCOUNT:
                procedure_variables += HAVOC_VARIABLE.format(ACCOUNTS_VARIABLE_NAME.format(CURRENT_TRANSACTION_INDEX, accounts_index))
                accounts_index += 1
            case abi.ABIReferenceType.APPLICATION:
                procedure_variables += HAVOC_VARIABLE.format(APPLICATIONS_VARIABLE_NAME.format(CURRENT_TRANSACTION_INDEX, applications_index))
                applications_index += 1
            case abi.ABIReferenceType.ASSET:
                procedure_variables += HAVOC_VARIABLE.format(ASSETS_VARIABLE_NAME.format(CURRENT_TRANSACTION_INDEX, assets_index))
                assets_index += 1
            #case abi.ABITransactionType.ANY | abi.ABITransactionType.PAY | abi.ABITransactionType.KEYREG | abi.ABITransactionType.ACFG | abi.ABITransactionType.AXFER | abi.ABITransactionType.AFRZ | abi.ABITransactionType.APPL:
            #    procedure_variables += HAVOC_VARIABLE.format(TRANSACTION_VARIABLE_NAME.format(transactions_group_offset))
            #    transactions_group_offset += 1
            #case _:
            #    Exception('Invalid type.')

    return procedure_variables

def method_procedure(method: abi.Method):
    #TODO: Handle creation and bare calls
    # TWO OPTIONS: with selector I may be able to recongnize the label called and based off that I can try to create a boogie version of it, calling in it with the arguments, VeriSol style. Or keep it simple and just call the parsed teal contract, and keep the variables global.
    procedure = method_initialization(method)
    #procedure += procedure_variables_declaration(method) # Not necessary given that variables are global
    procedure += method_variables_assigment(method)
    procedure += method_closure()
    return procedure

def to_camel_case(snake_str):
    return "".join(x.capitalize() for x in snake_str.lower().split("_"))

def to_lower_camel_case(snake_str):
    # We capitalize the first letter of each component except the first one
    # with the 'capitalize' method and join them together.
    camel_string = to_camel_case(snake_str)
    return snake_str[0].lower() + camel_string[1:]

def bare_call_procedures(bare_call_config: MethodConfigDict):
    procedures = ""
    for op_code in bare_call_config:
        procedure_name = to_lower_camel_case(op_code)
        procedure = PROCEDURE_DECLARATION.format(procedure_name)
        procedure += PROCEDURE_IMPLEMENTATION_BEGINNING.format(procedure_name)
        procedure += VARIABLE_ASSIGMENT.format(ON_COMPLETION_VARIABLE_NAME.format(CURRENT_TRANSACTION_INDEX, op_code_to_int[op_code]))
        procedure += CONTRACT_CALL
        procedure += PROCEDURE_IMPLEMENTATION_CLOSURE
        procedures += procedure
    return procedures

def main():
    n = len(argv)
    if (n <= 1):
        print("Missing path to JSON.")
        exit(-1)

    with open(argv[1], "r") as f:
        interface_json = f.read()

    interface = abi.Interface.from_json(interface_json)

    for method in interface.methods:
        print(method_procedure(method))

if __name__ == "__main__":
    main()

