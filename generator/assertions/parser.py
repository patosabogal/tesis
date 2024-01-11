import ply.yacc as yacc
from constants import GLOBAL_SLOTS, LOCAL_SLOTS
from definitions import ROOT_DIR
from methods import string_to_int

# Get the token map from the lexer. May look like it's not used but it's actually required.
from .lexer import tokens

def  p_triple_tokens(p):
    '''boolean_expression : boolean_expression AND boolean_term
       boolean_expression : boolean_expression OR boolean_term
       boolean_expression : boolean_expression EQUALS boolean_term
       boolean_expression : numeric_expression EQUALS numeric_term
       numeric_expression : numeric_expression PLUS numeric_term
       numeric_expression : numeric_expression MINUS numeric_term
       numeric_term : numeric_term TIMES numeric_factor
       numeric_term : numeric_term DIVIDE numeric_factor
       numeric_factor : LPAREN numeric_expression RPAREN
       boolean_factor : LPAREN boolean_expression RPAREN'''
    p[0] = f"{p[1]} {p[2]} {p[3]}"

def  p_unary_tokens(p):
    '''boolean_expression : boolean_term
    boolean_factor : BOOL
    boolean_term : boolean_factor
    numeric_expression : numeric_term
    numeric_term : numeric_factor
    numeric_factor : NUMBER'''
    p[0] = p[1]

def p_numeric_factor_global_number(p):
    '''
    numeric_factor : GLOBAL LBRACKET NUMBER RBRACKET
    '''
    p[0] = f"{GLOBAL_SLOTS}{p[2]}{p[3]}{p[4]}"

def p_numeric_factor_global_key(p):
    '''
    numeric_factor : GLOBAL LBRACKET KEY RBRACKET
    '''
    p[0] = f"{GLOBAL_SLOTS}{p[2]}{string_to_int(p[3])}{p[4]}"

def p_numeric_factor_local_key_number(p):
    '''
    numeric_factor : LOCAL LBRACKET ADDRESS RBRACKET LBRACKET NUMBER RBRACKET
    '''
    p[0] = f"{LOCAL_SLOTS}{string_to_int(p[2])}{p[3]}{p[4]}{p[5]}{p[6]}{p[7]}"

def p_numeric_factor_local_key_key(p):
    '''
    numeric_factor : LOCAL LBRACKET ADDRESS RBRACKET LBRACKET KEY RBRACKET
    '''
    p[0] = f"{LOCAL_SLOTS}{string_to_int(p[2])}{p[3]}{p[4]}{p[5]}{string_to_int(p[6])}{p[7]}"



# Error rule for syntax errors
def p_error(p):
    print(p)
    print("Syntax error in input!")

# Build the parser
parser = yacc.yacc(
        debug=False,
        tabmodule='artifacts.parsetab',
        outputdir=f'{ROOT_DIR}/artifacts/'
        )

if __name__ == '__main__':
    while True:
       try:
           s = input('calc > ')
       except EOFError:
           break
       if not s: continue
       result = parser.parse(s)
       print(result)
