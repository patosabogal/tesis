op_code_to_int = {
    "no_op": 0,
    "opt_in": 1,
    "close_out": 2,
    "clear_state": 3,
    "update_application": 4,
    "delete_application": 5
}
 # Max arguments size is actually 16, but the 15th slot is supposed to be encoded in some way to allow more arguments. TODO: look that up.
TRANSACTIONS_MAX_SIZE = 16
ARGUMENTS_MAX_SIZE = 15
# They can only have 8 values in total, between all of them. And the accounts array allows for a max of 4 accounts
FOREIGNS_MAX_COMBINED_SIZE = 8
ACCOUNTS_MAX_SIZE = 4

# TODO: Think if its worth to turn them into functions
#expects procedure name
PROCEDURE_DECLARATION = "procedure {}();\n"
PROCEDURE_IMPLEMENTATION_BEGINNING = "implementation {}(){{\n"

CONTRACT_CALL = "call contract();\n"
PROCEDURE_IMPLEMENTATION_CLOSURE = "}\n"

# expects variable name
INT_VARIABLE_DECLARATION = "var {} : int;\n"

# expects transaction
ON_COMPLETION_VARIABLE_NAME = "on_complete_{}"

# expects transaction and array index
ARGUMENTS_VARIABLE_NAME = "arguments_{}_{}"
ACCOUNTS_VARIABLE_NAME = "accounts_{}_{}"
APPLICATIONS_VARIABLE_NAME = "applications_{}_{}"
ASSETS_VARIABLE_NAME = "assets_{}_{}"
TRANSACTIONS_VARIABLE_NAME = "transaction_{}_{}"

SELECTOR_INDEX = 0
CURRENT_TRANSACTION_INDEX = 0

# expects variable name
HAVOC_VARIABLE = "havoc {};\n"

# expects variable name and value
VARIABLE_ASSIGMENT = "{} := {};\n"

