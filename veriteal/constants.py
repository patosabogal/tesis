from typing import Optional, Tuple, Sequence

opcode_to_int = {
    "no_op": 0,
    "opt_in": 1,
    "close_out": 2,
    "clear_state": 3,
    "update_application": 4,
    "delete_application": 5,
}

VERIFY_PROCEDURE = "verify"
NO_OP = "no_op"
DEFAULT_CONTRACT_CREATION_METHOD = "constructor"
CHOICE_VARIABLE_NAME = "choice"
RETURN_VARIABLE_NAME = "return_variable"
# Max arguments size is actually 16, but the 15th slot is supposed to be encoded in some way to allow more arguments. TODO: look that up.
TRANSACTIONS_MAX_SIZE = 16
SCRATCH_SLOTS = 64
TRANSACTIONS_ARRAYS_SIZE = 16
ARGUMENTS_MAX_SIZE = 16
# They can only have 8 values in total, between all of them. And the accounts array allows for a max of 4 accounts
FOREIGNS_MAX_COMBINED_SIZE = 8
ACCOUNTS_MAX_SIZE = 4
SELECTOR_INDEX = 0
CURRENT_TRANSACTION = "CurrentTx"
CURRENT_TRANSACTION_INDEX = -1
MAIN_CONTRACT_PROCEDURE_NAME = "contract"
GLOBAL_SLOTS = "Global"
LOCAL_SLOTS = "Local"


# expects procedure name
def procedure_name(name: str):
    return f"{name}"


def procedure_return(return_tuple: Optional[Tuple[str, str]]):
    return_string = ""
    if not (return_tuple is None):
        return_variable_name, return_variable_type = return_tuple
        return_string = f"returns ({return_variable_name}: {return_variable_type})"
    return return_string


def procedure_arguments(arguments: Sequence[Tuple[str, str]]):
    arguments_string = "("
    length = len(arguments)
    for index, argument in enumerate(arguments):
        argument_name, argument_type = argument
        separator = "" if index == length - 1 else ", "
        arguments_string += f"{argument_name}: {argument_type}{separator}"
    arguments_string += ")"
    return arguments_string


def procedure_declaration(
    name: str,
    arguments: Sequence[Tuple[str, str]] = [],
    return_tuple: Optional[Tuple[str, str]] = None,
):
    return f"procedure {procedure_name(name)}{procedure_arguments(arguments)}{procedure_return(return_tuple)};\n"


def procedure_implementation_beginning(
    name: str,
    arguments: Sequence[Tuple[str, str]] = [],
    return_tuple: Optional[Tuple[str, str]] = None,
):
    return f"implementation {procedure_name(name)}{procedure_arguments(arguments)}{procedure_return(return_tuple)}{{\n"


def procedure_implementation_closure():
    return "}\n\n"


def procedure_call(name: str):
    return f"call {procedure_name(name)}();\n"


def main_contract_call():
    return procedure_call(MAIN_CONTRACT_PROCEDURE_NAME)


def type_variable_declaration(type_name: str):
    def fn(var_name: str):
        return f"var {var_name} : {type_name};\n"

    return fn


int_variable_declaration = type_variable_declaration("int")
map_int_int_variable_declaration = type_variable_declaration("[int] int")
map_int_map_int_int_variable_declaration = type_variable_declaration("[int] [int] int")


def scratch_slot_variable_name(slot_index: int | str):
    return f"scratch_{slot_index}"


# expects transaction and array index
def array_variable_name(array: str):
    def fn(transaction_index: int, array_index: int):
        return f"{array}_{transaction_index}_{array_index}"

    return fn


def transaction_array_variable_name(
    array: str, transaction_index: int | str, array_index: int
):
    return f"{array}_{transaction_index}_{array_index}"


def transaction_field_variable_name(field: str, transaction_index: int | str):
    return f"{field}_{transaction_index}"


def transaction_field_access(field: str, transaction_index: str | int) -> str:
    return f"{field}_variable_lookup({transaction_index})"


def transaction_array_field_access(
    array_field: str, transaction_index: str | int, array_index: int | str
) -> str:
    return f"{array_field}_variable_lookup({transaction_index}, {array_index})"


def transaction_field_access_procedure(field: str) -> str:
    transaction_index_variable_name = "transaction_index"
    return_variable_variable_name = "variable"
    arguments = [(transaction_index_variable_name, "int")]
    return_tuple = (return_variable_variable_name, "int")
    procedure_string = ""
    procedure_string += procedure_declaration(
        f"{field}_variable_lookup", arguments, return_tuple
    )
    procedure_string += procedure_implementation_beginning(
        f"{field}_variable_lookup", arguments, return_tuple
    )
    procedure_string += (
        f"  if ({transaction_index_variable_name} == {CURRENT_TRANSACTION_INDEX}) {{\n"
    )
    procedure_string += f"    {return_variable_variable_name} := {transaction_field_variable_name(field, CURRENT_TRANSACTION)};\n"
    procedure_string += f"  }}\n"
    for transaction_index in range(0, TRANSACTIONS_MAX_SIZE):
        procedure_string += (
            f"  if ({transaction_index_variable_name} == {transaction_index}) {{\n"
        )
        procedure_string += f"    {return_variable_variable_name} := {transaction_field_variable_name(field, transaction_index)};\n"
        procedure_string += f"  }}\n"
    procedure_string += f"  return;\n"
    procedure_string += procedure_implementation_closure()
    return procedure_string


def transaction_array_field_access_procedure(field: str) -> str:
    transaction_index_variable_name = "transaction_index"
    array_index_variable_name = "array_index"
    return_variable_variable_name = "variable"
    arguments = [
        (transaction_index_variable_name, "int"),
        (array_index_variable_name, "int"),
    ]
    return_tuple = (return_variable_variable_name, "int")
    procedure_string = ""
    procedure_string += procedure_declaration(
        f"{field}_variable_lookup", arguments, return_tuple
    )
    procedure_string += procedure_implementation_beginning(
        f"{field}_variable_lookup", arguments, return_tuple
    )

    procedure_string += (
        f"  if ({transaction_index_variable_name} == {CURRENT_TRANSACTION_INDEX}) {{\n"
    )
    for array_index in range(0, TRANSACTIONS_ARRAYS_SIZE):
        procedure_string += (
            f"    if ({array_index_variable_name} == {array_index}) {{\n"
        )
        procedure_string += f"      {return_variable_variable_name} := {transaction_array_variable_name(field, CURRENT_TRANSACTION, array_index)};\n"
        procedure_string += f"    }}\n"
    procedure_string += f"  }}\n"
    for transaction_index in range(0, TRANSACTIONS_MAX_SIZE):
        procedure_string += (
            f"  if ({transaction_index_variable_name} == {transaction_index}) {{\n"
        )
        for array_index in range(0, TRANSACTIONS_ARRAYS_SIZE):
            procedure_string += (
                f"    if ({array_index_variable_name} == {array_index}) {{\n"
            )
            procedure_string += f"      {return_variable_variable_name} := {transaction_array_variable_name(field, transaction_index, array_index)};\n"
            procedure_string += f"    }}\n"
        procedure_string += f"  }}\n"
    procedure_string += f"  return;\n"
    procedure_string += procedure_implementation_closure()
    return procedure_string


transaction_array_fields = ["Accounts", "Applications", "Assets", "ApplicationArgs"]

accounts_variable_name = array_variable_name(transaction_array_fields[0])
applications_variable_name = array_variable_name(transaction_array_fields[1])
assets_variable_name = array_variable_name(transaction_array_fields[2])
arguments_variable_name = array_variable_name(transaction_array_fields[3])

type_enums = {
    "unknown": 0,
    "pay": 1,
    "keyreg": 2,
    "acfg": 3,
    "axfer": 4,
    "afrz": 5,
    "appl": 6,
}

global_fields = [
    "MinTxnFee",
    "MinBalance",
    "MaxTxnLife",
    "ZeroAddress",
    "GroupSize",
    "LogicSigVersion",
    "Round",
    "LatestTimestamp",
    "CurrentApplicationID",
    "CreatorAddress",
    "CurrentApplicationAddress",
    "GroupID",
    "OpcodeBudget",
    "CallerApplicationID",
    "CallerApplicationAddress",
    "AssetCreateMinBalance",
    "AssetOptInMinBalance",
    "GenesisHash",
]

transaction_fields = [
    "OnCompletion",
    "Sender",
    "Fee",
    "FirstValid",
    "FirstValidTime",
    "LastValid",
    "Note",
    "Lease",
    "Receiver",
    "Amount",
    "CloseRemainderTo",
    "VotePK",
    "SelectionPK",
    "VoteFirst",
    "VoteLast",
    "VoteKeyDilution",
    "Type",
    "TypeEnum",
    "XferAsset",
    "AssetAmount",
    "AssetSender",
    "AssetReceiver",
    "AssetCloseTo",
    "GroupIndex",
    "TxID",
    "ApplicationID",
    "NumAppArgs",
    "NumAccounts",
    "ApprovalProgram",
    "ClearStateProgram",
    "RekeyTo",
    "ConfigAsset",
    "ConfigAssetTotal",
    "ConfigAssetDecimals",
    "ConfigAssetDefaultFrozen",
    "ConfigAssetUnitName",
    "ConfigAssetName",
    "ConfigAssetURL",
    "ConfigAssetMetadataHash",
    "ConfigAssetManager",
    "ConfigAssetReserve",
    "ConfigAssetFreeze",
    "ConfigAssetClawback",
    "FreezeAsset",
    "FreezeAssetAccount",
    "FreezeAssetFrozen",
    "NumAssets",
    "NumApplications",
    "GlobalNumUint",
    "GlobalNumByteSlice",
    "LocalNumUint",
    "LocalNumByteSlice",
    "ExtraProgramPages",
    "Nonparticipation",
    "NumLogs",
    "CreatedAssetID",
    "CreatedApplicationID",
    "LastLog",
    "StateProofPK",
    "NumApprovalProgramPages",
    "NumClearStateProgramPages",
]

on_completion_variable_name = transaction_field_variable_name(
    transaction_fields[0], CURRENT_TRANSACTION
)


def global_map_access(key):
    return f"{GLOBAL_SLOTS}[{key}]"


def local_map_access(account, key):
    return f"{LOCAL_SLOTS}[{account}][{key}]"


# TODO: extract function builder
def phi_value_name(blocks_index: int, phi_index: int):
    return f"phi_value_{blocks_index}_{phi_index}"


def phi_variable_name(blocks_index: int, phi_index: int):
    return f"phi_{blocks_index}_{phi_index}"


def local_variable_name(instructions_index: int):
    return f"local_{instructions_index}"


def label_declaration(label_name_value: str | int):
    return f"{label_name(label_name_value)}:\n"


def label_name(name: int | str):
    return f"label_{name}"


EXIT_LABEL = label_name("exit")
EXIT_LABEL_BLOCK = f"""{EXIT_LABEL}:
assume {RETURN_VARIABLE_NAME} > 0;
return;\n"""


# expects variable name
def havoc_variable(var_name: str):
    return f"havoc {var_name};\n"


# expects variable name and value
def variable_assigment(var_name: str, value: int | str):
    return f"{var_name} := {value};\n"


def assume_global_slots_zero():
    return f"assume (forall key: int :: {GLOBAL_SLOTS}[key] == 0);\n"


def assume_current_tx_index():
    return f"assume {CURRENT_TRANSACTION} == {CURRENT_TRANSACTION_INDEX};\n"


def assume_default_theories():
    # TODO: assume scratch_slots 0 by default?
    return assume_global_slots_zero() + assume_current_tx_index()


def auxiliary_procedures():
    return select_procedure()


def pow_procedure():
    procedure_name = "pow"
    i = "i"
    x = "x"
    n = "n"
    r = "r"
    arguments = [(x, "int"), (n, "int")]
    return_type = (r, "int")
    procedure = procedure_declaration(procedure_name, arguments, return_type)
    procedure += procedure_implementation_beginning(
        procedure_name, arguments, return_type
    )
    procedure += int_variable_declaration(i)
    procedure += variable_assigment(i, 0)
    procedure += variable_assigment(r, 1)
    procedure += f"  while({i} < {n}) {{"
    procedure += f"    {r} = {r}*{n});"
    procedure += "   }}"
    procedure += f"  return;"
    procedure += procedure_implementation_closure()
    return procedure


def select_procedure() -> str:
    condition_variable_name = "condition"
    on_zero_variable_name = "on_zero"
    on_non_zero_variable_name = "on_non_zero"
    return_variable_variable_name = "variable"
    arguments = [
        (condition_variable_name, "int"),
        (on_zero_variable_name, "int"),
        (on_non_zero_variable_name, "int"),
    ]
    return_tuple = (return_variable_variable_name, "int")
    procedure_string = ""
    procedure_string += procedure_declaration(f"select", arguments, return_tuple)
    procedure_string += procedure_implementation_beginning(
        f"select", arguments, return_tuple
    )
    procedure_string += f"  if ({condition_variable_name} == 0) {{\n"
    procedure_string += (
        f"    {return_variable_variable_name} := {on_zero_variable_name};\n"
    )
    procedure_string += f"  }} else {{\n"
    procedure_string += (
        f"    {return_variable_variable_name} := {on_non_zero_variable_name};\n"
    )
    procedure_string += f"  }}\n"
    procedure_string += f"  return;\n"
    procedure_string += procedure_implementation_closure()
    return procedure_string


def functions_declarations() -> str:
    return """function to_int(x: bool) returns (int);
axiom to_int(false) == 0;
axiom to_int(true) == 1;

"""
