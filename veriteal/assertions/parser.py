import ply.yacc as yacc
from veriteal.constants import CURRENT_TRANSACTION, GLOBAL_SLOTS, LOCAL_SLOTS
from veriteal.definitions import ROOT_DIR
from veriteal.methods import string_to_int

# Get the token map from the lexer. May look like it's not used but it's actually required.
from veriteal.assertions.lexer import tokens


def p_triple_tokens(p):
    """
    boolean_expression : boolean_expression BOOLEAN_BOOLEAN_OPERATOR boolean_term
    boolean_expression : boolean_expression EQUALITY_OPERATOR boolean_term
    boolean_expression : numeric_expression EQUALITY_OPERATOR numeric_term
    boolean_expression : string_expression EQUALITY_OPERATOR string_term
    boolean_expression : storage_expression EQUALITY_OPERATOR string_term
    boolean_expression : storage_expression EQUALITY_OPERATOR numeric_expression
    boolean_expression : approves_expression EQUALITY_OPERATOR boolean_term
    boolean_expression : gtxn_expression EQUALITY_OPERATOR string_term
    boolean_expression : gtxn_expression EQUALITY_OPERATOR gtxn_term
    boolean_expression : gtxn_expression EQUALITY_OPERATOR numeric_term
    boolean_expression : numeric_expression EQUALITY_OPERATOR gtxn_term
    boolean_expression : global_field_expression EQUALITY_OPERATOR numeric_expression
    boolean_expression : gtxn_expression NUMERIC_BOOLEAN_OPERATOR numeric_expression
    boolean_expression : storage_expression NUMERIC_BOOLEAN_OPERATOR numeric_expression
    boolean_expression : numeric_expression NUMERIC_BOOLEAN_OPERATOR numeric_term
    numeric_expression : numeric_expression NUMERIC_NUMERIC_OPERATOR numeric_term
    numeric_expression : gtxn_expression NUMERIC_NUMERIC_OPERATOR numeric_term
    numeric_expression : gtxn_expression NUMERIC_NUMERIC_OPERATOR gtxn_term
    numeric_expression : numeric_expression NUMERIC_NUMERIC_OPERATOR gtxn_term
    numeric_factor : LPAREN numeric_expression RPAREN
    boolean_factor : LPAREN boolean_expression RPAREN
    """
    p[0] = f"{p[1]} {p[2]} {p[3]}"


def p_unary_tokens(p):
    """
    boolean_expression : boolean_term
    boolean_term : boolean_factor
    boolean_factor : BOOL
    numeric_expression : numeric_term
    numeric_term : numeric_factor
    numeric_factor : NUMBER
    string_expression : string_term
    string_term : string_factor
    storage_expression : storage_term
    approves_expression : approves_term
    approves_term : approves_factor
    approves_factor : APPROVES
    gtxn_expression : gtxn_term
    global_field_expression : global_field_term
    global_field_term : global_field_factor
    global_field_factor : GLOBAL_FIELD
    """
    p[0] = p[1]


# TODO: Keep adding string support. Add CurrentTx, Sender, ApplicationArgs support.
def p_string_address_factor(p):
    """
    string_factor : QUOTE STRING QUOTE
    string_factor : DOUBLE_QUOTE STRING DOUBLE_QUOTE
    address_factor : QUOTE ADDRESS QUOTE
    address_factor : DOUBLE_QUOTE ADDRESS DOUBLE_QUOTE
    """
    p[0] = f"{string_to_int(p[2])}"


def p_global_storage_term(p):
    """
    storage_term : GLOBAL_STORAGE LBRACKET numeric_factor RBRACKET
    storage_term : GLOBAL_STORAGE LBRACKET string_factor RBRACKET
    """
    p[0] = f"{GLOBAL_SLOTS}{p[2]}{p[3]}{p[4]}"


def p_local_storage_term(p):
    """
    storage_term : LOCAL_STORAGE LBRACKET address_factor RBRACKET LBRACKET RBRACKET
    storage_term : LOCAL_STORAGE LBRACKET address_factor RBRACKET LBRACKET string_factor RBRACKET
    """
    p[0] = f"{LOCAL_SLOTS}{p[2]}{p[3]}{p[4]}{p[5]}{p[6]}{p[7]}"


def p_group_transaction_field_term(p):
    """
    gtxn_term : GROUP_TXN LBRACKET numeric_factor RBRACKET DOT txn_field_factor
    """
    p[0] = f"{p[6]}_{p[3]}"


def p_group_transaction_array_field_term(p):
    """
    gtxn_term : GROUP_TXN LBRACKET numeric_factor RBRACKET DOT txna_field_factor LBRACKET numeric_factor RBRACKET
    """
    p[0] = f"{p[6]}_{p[3]}_{p[8]}"


def p_txn_field_term(p):
    """
    gtxn_term : txn_field_factor
    """
    p[0] = f"{p[1]}_{CURRENT_TRANSACTION}"


def p_txna_field_term(p):
    """
    gtxn_term : txna_field_factor LBRACKET numeric_factor RBRACKET
    """
    p[0] = f"{p[1]}_{CURRENT_TRANSACTION}_{p[3]}"


def p_txn_field_factor(p):
    """
    txn_field_factor : TXN_FIELD
    """
    p[0] = p[1]


def p_txna_field_factor(p):
    """
    txna_field_factor : TXNA_FIELD
    """
    p[0] = p[1]


# Error rule for syntax errors
def p_error(p):
    print(p)
    print("Syntax error in input!")


# Build the parser
parser = yacc.yacc(
    debug=False, tabmodule="artifacts.parsetab", outputdir=f"{ROOT_DIR}/artifacts/"
)

if __name__ == "__main__":
    while True:
        try:
            s = input("calc > ")
        except EOFError:
            break
        if not s:
            continue
        result = parser.parse(s)
        print(result)
