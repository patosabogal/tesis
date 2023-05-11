opcode_to_int = {
    "no_op": 0,
    "opt_in": 1,
    "close_out": 2,
    "clear_state": 3,
    "update_application": 4,
    "delete_application": 5
}

NO_OP = "no_op"
DEFAULT_CONTRACT_CREATION_METHOD = NO_OP
CHOICE_VARIABLE_NAME = "choice"
 # Max arguments size is actually 16, but the 15th slot is supposed to be encoded in some way to allow more arguments. TODO: look that up.
TRANSACTIONS_MAX_SIZE = 16
ARGUMENTS_MAX_SIZE = 15
# They can only have 8 values in total, between all of them. And the accounts array allows for a max of 4 accounts
FOREIGNS_MAX_COMBINED_SIZE = 8
ACCOUNTS_MAX_SIZE = 4
SELECTOR_INDEX = 0
CURRENT_TRANSACTION_INDEX = 0
MAIN_CONTRACT_PROCEDURE = "contract"
# TODO: Think if its worth to turn them into functions
#expects procedure name
def procedure_name(name: str):
    return f"{name}_"
def procedure_declaration(name: str):
    return f"procedure {procedure_name(name)}();\n"
def procedure_implementation_beginning(name: str):
    return f"implementation {procedure_name(name)}(){{\n"

def procedure_implementation_closure():
    return "}\n\n"

def procedure_call(name: str):
    return f"call {procedure_name(name)}();\n"

def main_contract_call():
    return procedure_call(MAIN_CONTRACT_PROCEDURE)

def int_variable_declaration(var_name: str):
    return f"var {var_name} : int;\n"

def on_completion_variable_name(transaction_index: int):
    return f"on_complete_{transaction_index}"

# expects transaction and array index
def array_variable_name(array: str):
    def fn(transaction_index: int, array_index: int):
        return f"{array}_{transaction_index}_{array_index}"
    return fn

arguments_variable_name = array_variable_name("arguments")
accounts_variable_name = array_variable_name("accounts")
applications_variable_name = array_variable_name("applications")
assets_variable_name = array_variable_name("assets")
# expects variable name
def havoc_variable(var_name: str):
    return f"havoc {var_name};\n"

# expects variable name and value
def variable_assigment(var_name: str, value: int):
    return f"{var_name} := {value};\n"

