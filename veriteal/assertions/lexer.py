import ply.lex as lex
from veriteal.definitions import ROOT_DIR

# List of token names.   This is always required
tokens = (
    "NUMBER",
    "BOOL",
    "EQUALITY_OPERATOR",
    "NUMERIC_BOOLEAN_OPERATOR",
    "BOOLEAN_BOOLEAN_OPERATOR",
    "NUMERIC_NUMERIC_OPERATOR",
    "LPAREN",
    "RPAREN",
    "QUOTE",
    "DOUBLE_QUOTE",
    "LBRACKET",
    "RBRACKET",
    "STRING",
    "LOCAL_STORAGE",
    "GLOBAL_STORAGE",
    "TXN_FIELD",
    "TXNA_FIELD",
    "ADDRESS",
    "DOT",
    "APPROVES",
    "GROUP_TXN",
    "GLOBAL_FIELD",
)

# Regular expression rules for simple tokens
# Tokens can also be defined as functio.
# A regular expression rule with some action code:


def t_LPAREN(t):
    r"\("
    return t


def t_RPAREN(t):
    r"\)"
    return t


def t_LBRACKET(t):
    r"\["
    return t


def t_RBRACKET(t):
    r"\]"
    return t


def t_QUOTE(t):
    r"\'"
    return t


def t_DOUBLE_QUOTE(t):
    r"\" "
    return t


def t_DOT(t):
    r"\."
    return t


def t_EQUALITY_OPERATOR(t):
    r"(\=\=|\!\=)"
    return t


def t_NUMERIC_BOOLEAN_OPERATOR(t):
    r"(\<\= | \< | \>\= | \>)"
    return t


def t_BOOLEAN_BOOLEAN_OPERATOR(t):
    r"(\&\& | \|\|)"
    return t


def t_NUMERIC_NUMERIC_OPERATOR(t):
    r"(\+ | \- | \* \/)"
    return t


def t_BOOL(t):
    r"(true|false)"
    return t


def t_NUMBER(t):
    r"\d+"
    return t


def t_GLOBAL_STORAGE(t):
    r"Global"
    return t


def t_LOCAL_STORAGE(t):
    r"Local"
    return t


def t_TXN_FIELD(t):
    r"(Sender | CurrentTx | Fee | Receiver | Amount | AssetReceiver | XferAsset)"
    return t


def t_TXNA_FIELD(t):
    r"(ApplicationArgs | Accounts)"
    return t


def t_GROUP_TXN(t):
    r"GroupTransaction"
    return t


def t_GLOBAL_FIELD(t):
    r"(GroupSize)"
    return t


def t_APPROVES(t):
    r"Approves"
    return t


def t_ADDRESS(t):
    r"(?:[A-Z2-7]{64})"
    return t


def t_STRING(t):
    r"(?:[a-zA-Z0-9]+)"
    return t


# Define a rule so we can track line numbers
def t_newline(t):
    r"\n+"
    t.lexer.lineno += len(t.value)


# A string containing ignored characters (spaces and tabs)
t_ignore = " \t"


# Error handling rule
def t_error(t):
    print("Illegal character '%s'" % t.value[0])
    t.lexer.skip(1)


# Build the lexer
lexer = lex.lex(outputdir=f"{ROOT_DIR}/artifacts/", debug=False)
