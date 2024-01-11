from typing import Optional, Tuple

opcode_to_int = {
    "no_op": 0,
    "opt_in": 1,
    "close_out": 2,
    "clear_state": 3,
    "update_application": 4,
    "delete_application": 5
}

VERIFY_PROCEDURE = "verify"
NO_OP = "no_op"
DEFAULT_CONTRACT_CREATION_METHOD = "constructor"
CHOICE_VARIABLE_NAME = "choice"
RETURN_VARIABLE_NAME = "return_variable"
# Max arguments size is actually 16, but the 15th slot is supposed to be encoded in some way to allow more arguments. TODO: look that up.
TRANSACTIONS_MAX_SIZE = 16
SCRATCH_SLOTS = 64
ARGUMENTS_MAX_SIZE = 15
# They can only have 8 values in total, between all of them. And the accounts array allows for a max of 4 accounts
FOREIGNS_MAX_COMBINED_SIZE = 8
ACCOUNTS_MAX_SIZE = 4
SELECTOR_INDEX = 0
CURRENT_TRANSACTION_INDEX = 0
MAIN_CONTRACT_PROCEDURE_NAME = "contract"
GLOBAL_SLOTS = "Global"
LOCAL_SLOTS = "Local"


# expects procedure name
def procedure_name(name: str):
    return f"{name}_"


def procedure_return(return_tuple):
    return_string = ""
    if not (return_tuple is None):
        return_variable_name, return_variable_type = return_tuple
        return_string = f"returns ({return_variable_name}: {return_variable_type})"
    return return_string


def procedure_declaration(name: str, return_tuple: Optional[Tuple[str, str]] = None):
    return f"procedure {procedure_name(name)}(){procedure_return(return_tuple)};\n"


def procedure_implementation_beginning(name: str, return_tuple: Optional[Tuple[str, str]] = None):
    return f"implementation {procedure_name(name)}(){procedure_return(return_tuple)}{{\n"


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


def on_completion_variable_name(transaction_index: int):
    return f"on_complete_{transaction_index}"


def scratch_slot_variable_name(slot_index: int | str):
    return f"scratch_{slot_index}"


# expects transaction and array index
def array_variable_name(array: str):
    def fn(transaction_index: int, array_index: int):
        return f"{array}_{transaction_index}_{array_index}"

    return fn


arguments_variable_name = array_variable_name("arguments")
accounts_variable_name = array_variable_name("accounts")
applications_variable_name = array_variable_name("applications")
assets_variable_name = array_variable_name("assets")


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


def label_declaration(label_name_value: str):
    return f"{label_name(label_name_value)}:\n"


def label_name(name: int | str):
    return f"label_{name}"


EXIT_LABEL = label_name("exit")
EXIT_LABEL_BLOCK = f"""{EXIT_LABEL}:
return;\n"""


# expects variable name
def havoc_variable(var_name: str):
    return f"havoc {var_name};\n"


# expects variable name and value
def variable_assigment(var_name: str, value: int | str):
    return f"{var_name} := {value};\n"


def functions_declarations() -> str:
    return """function to_int(x: bool) returns (int);
axiom to_int(false) == 0;
axiom to_int(true) == 1;

"""

