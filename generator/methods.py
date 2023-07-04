# TODO: DO NOT * IMPORT
from constants import *
from sys import argv
from algosdk import abi
from Crypto.Hash import keccak, SHA512
from algokit_utils import MethodConfigDict, MethodHints, OnCompleteActionName


def method_initialization(method: abi.Method):
    procedure_initialization = procedure_declaration(method.name)
    procedure_initialization += procedure_implementation_beginning(method.name)
    return procedure_initialization

def method_closure():
    procedure_closure = main_contract_call()
    procedure_closure += procedure_implementation_closure()
    return procedure_closure


def string_to_int(string: str):
    hash_function = SHA512.new(truncate="256")
    hash_function.update(string.encode("utf-8"))
    return bytes_to_int(hash_function.digest()[:4])


def bytes_to_int(bytes_string: bytes):
    k = keccak.new(digest_bits=256)
    k.update(bytes_string)
    hex_value = k.hexdigest()
    return int(hex_value, 16)

def method_variables_declaration(method: abi.Method):
    procedure_variables = ""
    arguments_index = 1 # 0 is method signature
    accounts_index = 1 # 0 is sender
    applications_index = 1 # 0 is current_application_id
    assets_index = 0 # starts empyt unless trnasaction is an asset_transfer, which is not

    for arg in method.args:
        match arg.type:
            case abi.UintType() | abi.BoolType() | abi.StringType():
                procedure_variables += int_variable_declaration(arguments_variable_name(CURRENT_TRANSACTION_INDEX, arguments_index))
                arguments_index += 1
            case abi.ABIReferenceType.ACCOUNT:
                procedure_variables += int_variable_declaration(accounts_variable_name(CURRENT_TRANSACTION_INDEX, accounts_index))
                accounts_index += 1
            case abi.ABIReferenceType.APPLICATION:
                procedure_variables += int_variable_declaration(applications_variable_name(CURRENT_TRANSACTION_INDEX, applications_index))
                applications_index += 1
            case abi.ABIReferenceType.ASSET:
                procedure_variables += int_variable_declaration(assets_variable_name(CURRENT_TRANSACTION_INDEX,assets_index))
                assets_index += 1

    return procedure_variables

def method_variables_assigment(method: abi.Method):
    procedure_variables = variable_assigment(arguments_variable_name(CURRENT_TRANSACTION_INDEX, SELECTOR_INDEX), bytes_to_int(method.get_selector()))
    arguments_index = 1 # 0 is method signature
    accounts_index = 1 # 0 is sender
    applications_index = 1 # 0 is current_application_id
    assets_index = 0 # starts empyt unless trnasaction is an asset_transfer, which is not

    for arg in method.args:
        match arg.type:
            case abi.UintType() | abi.BoolType() | abi.StringType():
                procedure_variables += havoc_variable(arguments_variable_name(CURRENT_TRANSACTION_INDEX, arguments_index))
                arguments_index += 1
            case abi.ABIReferenceType.ACCOUNT:
                procedure_variables += havoc_variable(accounts_variable_name(CURRENT_TRANSACTION_INDEX, accounts_index))
                accounts_index += 1
            case abi.ABIReferenceType.APPLICATION:
                procedure_variables += havoc_variable(applications_variable_name(CURRENT_TRANSACTION_INDEX, applications_index))
                applications_index += 1
            case abi.ABIReferenceType.ASSET:
                procedure_variables += havoc_variable(assets_variable_name(CURRENT_TRANSACTION_INDEX, assets_index))
                assets_index += 1

    return procedure_variables

def hint_on_completion_int(hint: MethodHints) -> str:
    return list(hint.call_config.keys())[0]

# TODO: MERGE METHOD_PROCEDURE AND BARE_CALL_PROCEDURE
def method_procedure(method: abi.Method, hint: MethodHints) -> str:
    # TWO OPTIONS: with selector I may be able to recongnize the label called and based off that I can try to create a boogie version of it, calling in it with the arguments, VeriSol style. Or keep it simple and just call the parsed teal contract, and keep the variables global.
    procedure = method_initialization(method)
    procedure += method_variables_assigment(method)
    procedure += variable_assigment(on_completion_variable_name(CURRENT_TRANSACTION_INDEX ),opcode_to_int[hint_on_completion_int(hint)])
    procedure += method_closure()
    return procedure

def bare_call_procedure(opcode: OnCompleteActionName):
    procedure = procedure_declaration(opcode)
    procedure += procedure_implementation_beginning(opcode)
    procedure += variable_assigment(on_completion_variable_name(CURRENT_TRANSACTION_INDEX ), opcode_to_int[opcode])
    procedure += main_contract_call()
    procedure += procedure_implementation_closure()
    return procedure
