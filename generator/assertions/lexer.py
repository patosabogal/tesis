import ply.lex as lex
from definitions import ROOT_DIR

# List of token names.   This is always required
tokens = (
   'NUMBER',
   'BOOL',
   'PLUS',
   'MINUS',
   'TIMES',
   'DIVIDE',
   'LPAREN',
   'RPAREN',
   'EQUALS',
   'AND',
   'OR',
   'LOCAL',
   'LBRACKET',
   'RBRACKET',
   'KEY',
   'GLOBAL',
   'ADDRESS'
)

# Regular expression rules for simple tokens
# Tokens can also be defined as functio.
# A regular expression rule with some action code:

t_PLUS    = r'\+'
t_MINUS   = r'-'
t_TIMES   = r'\*'
t_DIVIDE  = r'/'
t_LPAREN  = r'\('
t_RPAREN  = r'\)'
t_LBRACKET  = r'\['
t_RBRACKET  = r'\]'
t_EQUALS  = r'\=\='
t_AND  = r'\&\&'
t_OR  = r'or'
t_BOOL  = r'(true|false)'
t_NUMBER  = r'\d+'
t_GLOBAL = r'global'
t_LOCAL = r'local'

def t_ADDRESS(t):
    r'(\"(?:[A-Z2-7]{64})\"|\'(?:[A-Z2-7]{64})\')'
    return t

def t_KEY(t):
    r'(\"(?:[a-zA-Z0-9]+)\"|\'(?:[a-zA-Z0-9]+)\')'
    return t


# Define a rule so we can track line numbers
def t_newline(t):
    r'\n+'
    t.lexer.lineno += len(t.value)

# A string containing ignored characters (spaces and tabs)
t_ignore  = ' \t'

# Error handling rule
def t_error(t):
    print("Illegal character '%s'" % t.value[0])
    t.lexer.skip(1)

# Build the lexer
lexer = lex.lex(
        outputdir=f'{ROOT_DIR}/artifacts/',
        debug=False
        )
