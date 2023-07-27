# TODO: DO NOT * IMPORT
from typing import List

from constants import *
from dataclasses import dataclass
from algosdk import abi
from Crypto.Hash import keccak, SHA512
from algokit_utils import MethodHints, OnCompleteActionName, CallConfig, MethodConfigDict

ReservedApplicationArray = List[str]
RequiredApplicationArray = List[Tuple[int, str]]


def foreigns_array_builder(array_type):
    @dataclass
    class Arr:
        arguments: array_type
        assets: array_type
        applications: array_type
        accounts: array_type

    return Arr


RequiredArrays = foreigns_array_builder(RequiredApplicationArray)
ReservedArrays = foreigns_array_builder(ReservedApplicationArray)


@dataclass
class Method:
    name: str
    opcode: int
    required: RequiredArrays
    reserved: ReservedArrays
    constructor: bool = False

    @staticmethod
    def from_abi_method(method: abi.Method, hint: MethodHints):
        required_arguments = [(0, bytes_to_int(method.get_selector()))]

        arguments_index = 1  # 0 is method signature
        accounts_index = 1  # 0 is sender
        applications_index = 1  # 0 is current_application_id
        assets_index = 0  # starts empty unless transaction is an asset_transfer, which is not
        reserved_arguments = []
        reserved_assets = []
        reserved_accounts = []
        reserved_applications = []

        for arg in method.args:
            match arg.type:
                case abi.UintType() | abi.BoolType() | abi.StringType():
                    reserved_arguments.append(arguments_index)
                    arguments_index += 1
                case abi.ABIReferenceType.ACCOUNT:
                    reserved_accounts.append(accounts_index)
                    accounts_index += 1
                case abi.ABIReferenceType.APPLICATION:
                    reserved_applications.append(applications_index)
                    applications_index += 1
                case abi.ABIReferenceType.ASSET:
                    reserved_assets.append(assets_index)
                    assets_index += 1

        required = RequiredArrays(required_arguments, [], [], [])
        reserved = ReservedArrays(reserved_arguments, reserved_assets, reserved_applications, reserved_accounts)
        opcode, config = list(hint.call_config.items())[0]
        opcode_int = opcode_to_int[opcode]

        return Method(method.name, opcode_int, required, reserved, constructor=config == CallConfig.CREATE)

    @staticmethod
    def from_bare_call(opcode: OnCompleteActionName, call_config: CallConfig):
        required = RequiredArrays([], [], [], [])
        reserved = ReservedArrays([], [], [], [])
        opcode_int = opcode_to_int[opcode]

        return Method(opcode, opcode_int, required, reserved, constructor=call_config == CallConfig.CREATE)

    @staticmethod
    def from_dict(method: dict):
        reserved = ReservedArrays(
            method['reserved']['arguments'],
            method['reserved']['assets'],
            method['reserved']['applications'],
            method['reserved']['accounts'],
        )
        required = RequiredArrays(
            list(map(lambda key, value: (int(key), value), method['required']['arguments'].items())),
            list(map(lambda key, value: (int(key), value), method['required']['assets'].items())),
            list(map(lambda key, value: (int(key), value), method['required']['applications'].items())),
            list(map(lambda key, value: (int(key), value), method['required']['accounts'].items())),
        )

        opcode_int = method['opcode']
        name = method['name']

        return Method(name, opcode_int, required, reserved, constructor=name == DEFAULT_CONTRACT_CREATION_METHOD)


def method_initialization(method_name: str):
    procedure_initialization = procedure_declaration(method_name)
    procedure_initialization += procedure_implementation_beginning(method_name)
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


# def method_variables_declaration(method: abi.Method):
#    procedure_variables = ""
#    arguments_index = 1  # 0 is method signature
#    accounts_index = 1  # 0 is sender
#    applications_index = 1  # 0 is current_application_id
#    assets_index = 0  # starts empyt unless trnasaction is an asset_transfer, which is not
#
#    for arg in method.args:
#        match arg.type:
#            case abi.UintType() | abi.BoolType() | abi.StringType():
#                procedure_variables += int_variable_declaration(
#                    arguments_variable_name(CURRENT_TRANSACTION_INDEX, arguments_index))
#                arguments_index += 1
#            case abi.ABIReferenceType.ACCOUNT:
#                procedure_variables += int_variable_declaration(
#                    accounts_variable_name(CURRENT_TRANSACTION_INDEX, accounts_index))
#                accounts_index += 1
#            case abi.ABIReferenceType.APPLICATION:
#                procedure_variables += int_variable_declaration(
#                    applications_variable_name(CURRENT_TRANSACTION_INDEX, applications_index))
#                applications_index += 1
#            case abi.ABIReferenceType.ASSET:
#                procedure_variables += int_variable_declaration(
#                    assets_variable_name(CURRENT_TRANSACTION_INDEX, assets_index))
#                assets_index += 1
#
#    return procedure_variables


def method_variables_assigment(method: Method):
    procedure_variables = ""
    separator = ""

    def required_mapping_function_builder(variable_name):
        def required_mapping_function(current):
            index, value = current
            return variable_assigment(variable_name(CURRENT_TRANSACTION_INDEX, index), value)

        return required_mapping_function

    def reserved_mapping_function_builder(variable_name):
        def reserved_mapping_function(current):
            return havoc_variable(variable_name(CURRENT_TRANSACTION_INDEX, current))

        return reserved_mapping_function

    required_arguments_mapping = required_mapping_function_builder(arguments_variable_name)
    required_assets_mapping = required_mapping_function_builder(assets_variable_name)
    required_applications_mapping = required_mapping_function_builder(applications_variable_name)
    required_accounts_mapping = required_mapping_function_builder(accounts_variable_name)

    reserved_arguments_mapping = reserved_mapping_function_builder(arguments_variable_name)
    reserved_assets_mapping = reserved_mapping_function_builder(assets_variable_name)
    reserved_applications_mapping = reserved_mapping_function_builder(applications_variable_name)
    reserved_accounts_mapping = reserved_mapping_function_builder(accounts_variable_name)

    procedure_variables += separator.join(map(required_arguments_mapping, method.required.arguments))
    procedure_variables += separator.join(map(required_assets_mapping, method.required.assets))
    procedure_variables += separator.join(map(required_applications_mapping, method.required.applications))
    procedure_variables += separator.join(map(required_accounts_mapping, method.required.accounts))

    procedure_variables += separator.join(map(reserved_arguments_mapping, method.reserved.arguments))
    procedure_variables += separator.join(map(reserved_assets_mapping, method.reserved.assets))
    procedure_variables += separator.join(map(reserved_applications_mapping, method.reserved.applications))
    procedure_variables += separator.join(map(reserved_accounts_mapping, method.reserved.accounts))

    return procedure_variables


# def method_variables_assigment(method: abi.Method):
#    procedure_variables = variable_assigment(arguments_variable_name(CURRENT_TRANSACTION_INDEX, SELECTOR_INDEX),
#                                             bytes_to_int(method.get_selector()))
#    arguments_index = 1  # 0 is method signature
#    accounts_index = 1  # 0 is sender
#    applications_index = 1  # 0 is current_application_id
#    assets_index = 0  # starts empyt unless trnasaction is an asset_transfer, which is not
#
#    for arg in method.args:
#        match arg.type:
#            case abi.UintType() | abi.BoolType() | abi.StringType():
#                procedure_variables += havoc_variable(
#                    arguments_variable_name(CURRENT_TRANSACTION_INDEX, arguments_index))
#                arguments_index += 1
#            case abi.ABIReferenceType.ACCOUNT:
#                procedure_variables += havoc_variable(accounts_variable_name(CURRENT_TRANSACTION_INDEX, accounts_index))
#                accounts_index += 1
#            case abi.ABIReferenceType.APPLICATION:
#                procedure_variables += havoc_variable(
#                    applications_variable_name(CURRENT_TRANSACTION_INDEX, applications_index))
#                applications_index += 1
#            case abi.ABIReferenceType.ASSET:
#                procedure_variables += havoc_variable(assets_variable_name(CURRENT_TRANSACTION_INDEX, assets_index))
#                assets_index += 1
#
#    return procedure_variables


# def get_on_completion_from_hint(hint: MethodHints) -> str:
#    return list(hint.call_config.keys())[0]


def method_procedure(method: Method) -> str:
    procedure = method_initialization(method.name)
    procedure += method_variables_assigment(method)
    procedure += variable_assigment(
        on_completion_variable_name(CURRENT_TRANSACTION_INDEX),
        method.opcode
    )
    procedure += method_closure()
    return procedure

# TODO: MERGE METHOD_PROCEDURE AND BARE_CALL_PROCEDURE
# def method_procedure(method: abi.Method, hint: MethodHints) -> str:
#    # TWO OPTIONS: with selector I may be able to recognize the label called and based off that,
#    # I can try to create a boogie version of it, calling in it with the arguments, VeriSol style.
#    # Or keep it simple and just call the parsed teal contract, and keep the variables global.
#    procedure = method_initialization(method.name)
#    procedure += method_variables_assigment(method)
#    procedure += variable_assigment(
#        on_completion_variable_name(CURRENT_TRANSACTION_INDEX),
#        opcode_to_int[get_on_completion_from_hint(hint)]
#    )
#    procedure += method_closure()
#    return procedure


# def bare_call_procedure(opcode: OnCompleteActionName):
#    procedure = procedure_declaration(opcode)
#    procedure += procedure_implementation_beginning(opcode)
#    procedure += variable_assigment(on_completion_variable_name(CURRENT_TRANSACTION_INDEX), opcode_to_int[opcode])
#    procedure += main_contract_call()
#    procedure += procedure_implementation_closure()
#    return procedure
