import ply.lex as lex
from veriteal.definitions import ROOT_DIR

# List of token names.   This is always required
tokens = (
    "NUMBER",
    "BOOL",
    "PLUS",
    "MINUS",
    "TIMES",
    "DIVIDE",
    "LPAREN",
    "RPAREN",
    "QUOTE",
    "DOUBLE_QUOTE",
    "EQUALS",
    "LESSER",
    "LESSER_OR_EQUALS",
    "GREATER",
    "GREATER_OR_EQUALS",
    "AND",
    "OR",
    "LOCAL",
    "LBRACKET",
    "RBRACKET",
    "STRING",
    "GLOBAL",
    "TXN_FIELD",
    "TXNA_FIELD",
    "ADDRESS",
    "DOT",
    "APPROVES",
    "GROUP_TXN",
)

# Regular expression rules for simple tokens
# Tokens can also be defined as functio.
# A regular expression rule with some action code:


def t_PLUS(t):
    r"\+"
    return t


def t_MINUS(t):
    r"-"
    return t


def t_TIMES(t):
    r"\*"
    return t


def t_DIVIDE(t):
    r"/"
    return t


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


def t_EQUALS(t):
    r"\=\="
    return t


def t_LESSER(t):
    r"\<"
    return t


def t_LESSER_OR_EQUALS(t):
    r"\<\="
    return t


def t_GREATER(t):
    r"\>"
    return t


def t_GREATER_OR_EQUALS(t):
    r"\>\="
    return t


def t_AND(t):
    r"\&\&"
    return t


def t_OR(t):
    r"or"
    return t


def t_BOOL(t):
    r"(true|false)"
    return t


def t_NUMBER(t):
    r"\d+"
    return t


def t_GLOBAL(t):
    r"Global"
    return t


def t_LOCAL(t):
    r"Local"
    return t


def t_TXN_FIELD(t):
    r"(Sender | CurrentTx)"
    return t


def t_TXNA_FIELD(t):
    r"(ApplicationArgs)"
    return t


def t_GROUP_TXN(t):
    r"GroupTransaction"
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
