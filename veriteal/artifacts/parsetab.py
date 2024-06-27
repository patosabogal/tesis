
# parsetab.py
# This file is automatically generated. Do not edit.
# pylint: disable=W,C,R
_tabversion = '3.10'

_lr_method = 'LALR'

_lr_signature = 'ADDRESS AND APPROVES BOOL DIVIDE DOT DOUBLE_QUOTE EQUALS GLOBAL GREATER GREATER_OR_EQUALS GROUP_TXN LBRACKET LESSER LESSER_OR_EQUALS LOCAL LPAREN MINUS NUMBER OR PLUS QUOTE RBRACKET RPAREN STRING TIMES TXNA_FIELD TXN_FIELD\n    boolean_expression : boolean_expression AND boolean_term\n    boolean_expression : boolean_expression OR boolean_term\n    boolean_expression : boolean_expression EQUALS boolean_term\n    boolean_expression : numeric_expression EQUALS numeric_term\n    boolean_expression : string_expression EQUALS string_term\n    boolean_expression : storage_expression EQUALS string_term\n    boolean_expression : storage_expression EQUALS numeric_expression\n    boolean_expression : approves_expression EQUALS boolean_term\n    boolean_expression : gtxn_term EQUALS numeric_expression\n    boolean_expression : gtxn_term EQUALS string_term\n    boolean_expression : storage_expression LESSER numeric_expression\n    boolean_expression : storage_expression GREATER numeric_expression\n    boolean_expression : storage_expression LESSER_OR_EQUALS numeric_expression\n    boolean_expression : storage_expression GREATER_OR_EQUALS numeric_expression\n    boolean_expression : numeric_expression LESSER numeric_term\n    boolean_expression : numeric_expression LESSER_OR_EQUALS numeric_term\n    boolean_expression : numeric_expression GREATER numeric_term\n    boolean_expression : numeric_expression GREATER_OR_EQUALS numeric_term\n    numeric_expression : numeric_expression PLUS numeric_term\n    numeric_expression : numeric_expression MINUS numeric_term\n    numeric_term : numeric_term TIMES numeric_factor\n    numeric_term : numeric_term DIVIDE numeric_factor\n    numeric_factor : LPAREN numeric_expression RPAREN\n    boolean_factor : LPAREN boolean_expression RPAREN\n    \n    boolean_expression : boolean_term\n    boolean_term : boolean_factor\n    boolean_factor : BOOL\n    numeric_expression : numeric_term\n    numeric_term : numeric_factor\n    numeric_factor : NUMBER\n    string_expression : string_term\n    string_term : string_factor\n    storage_expression : storage_term\n    approves_expression : approves_term\n    approves_term : approves_factor\n    approves_factor : APPROVES\n    \n    string_factor : QUOTE STRING QUOTE\n    string_factor : DOUBLE_QUOTE STRING DOUBLE_QUOTE\n    address_factor : QUOTE ADDRESS QUOTE\n    address_factor : DOUBLE_QUOTE ADDRESS DOUBLE_QUOTE\n    \n    storage_term : GLOBAL LBRACKET numeric_factor RBRACKET\n    storage_term : GLOBAL LBRACKET string_factor RBRACKET\n    \n    storage_term : LOCAL LBRACKET address_factor RBRACKET LBRACKET RBRACKET\n    storage_term : LOCAL LBRACKET address_factor RBRACKET LBRACKET string_factor RBRACKET\n    \n    gtxn_term : GROUP_TXN LBRACKET numeric_factor RBRACKET DOT txn_field_factor\n    \n    gtxn_term : GROUP_TXN LBRACKET numeric_factor RBRACKET DOT txna_field_factor LBRACKET numeric_factor RBRACKET\n    \n    gtxn_term : txn_field_factor\n    \n    gtxn_term : txna_field_factor LBRACKET numeric_factor RBRACKET\n    \n    txn_field_factor : TXN_FIELD\n    \n    txna_field_factor : TXNA_FIELD\n    '
    
_lr_action_items = {'GROUP_TXN':([0,23,58,],[12,12,12,]),'GLOBAL':([0,23,58,],[18,18,18,]),'LOCAL':([0,23,58,],[19,19,19,]),'TXN_FIELD':([0,23,58,100,],[21,21,21,21,]),'TXNA_FIELD':([0,23,58,100,],[22,22,22,22,]),'LPAREN':([0,23,29,30,31,32,33,34,35,36,37,38,39,40,42,43,44,45,46,47,48,49,50,51,58,62,108,],[23,23,58,58,58,62,62,62,62,62,62,62,62,62,62,62,62,62,62,58,62,62,62,62,23,62,62,]),'BOOL':([0,23,29,30,31,47,58,],[24,24,24,24,24,24,24,]),'NUMBER':([0,23,32,33,34,35,36,37,38,39,40,42,43,44,45,46,48,49,50,51,58,62,108,],[25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,25,]),'QUOTE':([0,23,41,42,48,51,52,55,58,98,101,],[26,26,26,26,26,26,86,90,26,102,26,]),'DOUBLE_QUOTE':([0,23,41,42,48,51,52,56,58,99,101,],[27,27,27,27,27,27,87,91,27,103,27,]),'APPROVES':([0,23,58,],[28,28,28,]),'$end':([1,2,4,13,16,17,24,25,57,59,60,61,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,88,89,90,91,],[0,-25,-28,-29,-26,-32,-27,-30,-1,-2,-3,-4,-15,-16,-17,-18,-19,-20,-21,-22,-5,-6,-7,-11,-12,-13,-14,-8,-9,-10,-24,-23,-37,-38,]),'AND':([1,2,4,13,16,17,24,25,53,57,59,60,61,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,88,89,90,91,],[29,-25,-28,-29,-26,-32,-27,-30,29,-1,-2,-3,-4,-15,-16,-17,-18,-19,-20,-21,-22,-5,-6,-7,-11,-12,-13,-14,-8,-9,-10,-24,-23,-37,-38,]),'OR':([1,2,4,13,16,17,24,25,53,57,59,60,61,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,88,89,90,91,],[30,-25,-28,-29,-26,-32,-27,-30,30,-1,-2,-3,-4,-15,-16,-17,-18,-19,-20,-21,-22,-5,-6,-7,-11,-12,-13,-14,-8,-9,-10,-24,-23,-37,-38,]),'EQUALS':([1,2,3,4,5,6,7,8,9,10,11,13,14,16,17,20,21,24,25,28,53,54,57,59,60,61,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,88,89,90,91,94,95,96,104,106,109,111,],[31,-25,32,-28,41,-31,42,47,48,-33,-34,-29,-47,-26,-32,-35,-49,-27,-30,-36,31,32,-1,-2,-3,-4,-15,-16,-17,-18,-19,-20,-21,-22,-5,-6,-7,-11,-12,-13,-14,-8,-9,-10,-24,-23,-37,-38,-48,-41,-42,-45,-43,-44,-46,]),'RPAREN':([2,4,13,16,17,24,25,53,54,57,59,60,61,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,88,89,90,91,92,],[-25,-28,-29,-26,-32,-27,-30,88,89,-1,-2,-3,-4,-15,-16,-17,-18,-19,-20,-21,-22,-5,-6,-7,-11,-12,-13,-14,-8,-9,-10,-24,-23,-37,-38,89,]),'LESSER':([3,4,7,10,13,25,54,67,68,69,70,89,95,96,106,109,],[33,-28,43,-33,-29,-30,33,-19,-20,-21,-22,-23,-41,-42,-43,-44,]),'LESSER_OR_EQUALS':([3,4,7,10,13,25,54,67,68,69,70,89,95,96,106,109,],[34,-28,45,-33,-29,-30,34,-19,-20,-21,-22,-23,-41,-42,-43,-44,]),'GREATER':([3,4,7,10,13,25,54,67,68,69,70,89,95,96,106,109,],[35,-28,44,-33,-29,-30,35,-19,-20,-21,-22,-23,-41,-42,-43,-44,]),'GREATER_OR_EQUALS':([3,4,7,10,13,25,54,67,68,69,70,89,95,96,106,109,],[36,-28,46,-33,-29,-30,36,-19,-20,-21,-22,-23,-41,-42,-43,-44,]),'PLUS':([3,4,13,25,54,67,68,69,70,73,74,75,76,77,79,89,92,],[37,-28,-29,-30,37,-19,-20,-21,-22,37,37,37,37,37,37,-23,37,]),'MINUS':([3,4,13,25,54,67,68,69,70,73,74,75,76,77,79,89,92,],[38,-28,-29,-30,38,-19,-20,-21,-22,38,38,38,38,38,38,-23,38,]),'TIMES':([4,13,25,61,63,64,65,66,67,68,69,70,89,],[39,-29,-30,39,39,39,39,39,39,39,-21,-22,-23,]),'DIVIDE':([4,13,25,61,63,64,65,66,67,68,69,70,89,],[40,-29,-30,40,40,40,40,40,40,40,-21,-22,-23,]),'LBRACKET':([12,15,18,19,22,97,105,],[49,50,51,52,-50,101,108,]),'RBRACKET':([25,81,82,83,84,85,89,90,91,101,102,103,107,110,],[-30,93,94,95,96,97,-23,-37,-38,106,-39,-40,109,111,]),'STRING':([26,27,],[55,56,]),'ADDRESS':([86,87,],[98,99,]),'DOT':([93,],[100,]),}

_lr_action = {}
for _k, _v in _lr_action_items.items():
   for _x,_y in zip(_v[0],_v[1]):
      if not _x in _lr_action:  _lr_action[_x] = {}
      _lr_action[_x][_k] = _y
del _lr_action_items

_lr_goto_items = {'boolean_expression':([0,23,58,],[1,53,53,]),'boolean_term':([0,23,29,30,31,47,58,],[2,2,57,59,60,78,2,]),'numeric_expression':([0,23,42,43,44,45,46,48,58,62,],[3,54,73,74,75,76,77,79,3,92,]),'numeric_term':([0,23,32,33,34,35,36,37,38,42,43,44,45,46,48,58,62,],[4,4,61,63,64,65,66,67,68,4,4,4,4,4,4,4,4,]),'string_expression':([0,23,58,],[5,5,5,]),'string_term':([0,23,41,42,48,58,],[6,6,71,72,80,6,]),'storage_expression':([0,23,58,],[7,7,7,]),'approves_expression':([0,23,58,],[8,8,8,]),'gtxn_term':([0,23,58,],[9,9,9,]),'storage_term':([0,23,58,],[10,10,10,]),'approves_term':([0,23,58,],[11,11,11,]),'numeric_factor':([0,23,32,33,34,35,36,37,38,39,40,42,43,44,45,46,48,49,50,51,58,62,108,],[13,13,13,13,13,13,13,13,13,69,70,13,13,13,13,13,13,81,82,83,13,13,110,]),'txn_field_factor':([0,23,58,100,],[14,14,14,104,]),'txna_field_factor':([0,23,58,100,],[15,15,15,105,]),'boolean_factor':([0,23,29,30,31,47,58,],[16,16,16,16,16,16,16,]),'string_factor':([0,23,41,42,48,51,58,101,],[17,17,17,17,17,84,17,107,]),'approves_factor':([0,23,58,],[20,20,20,]),'address_factor':([52,],[85,]),}

_lr_goto = {}
for _k, _v in _lr_goto_items.items():
   for _x, _y in zip(_v[0], _v[1]):
       if not _x in _lr_goto: _lr_goto[_x] = {}
       _lr_goto[_x][_k] = _y
del _lr_goto_items
_lr_productions = [
  ("S' -> boolean_expression","S'",1,None,None,None),
  ('boolean_expression -> boolean_expression AND boolean_term','boolean_expression',3,'p_triple_tokens','parser.py',11),
  ('boolean_expression -> boolean_expression OR boolean_term','boolean_expression',3,'p_triple_tokens','parser.py',12),
  ('boolean_expression -> boolean_expression EQUALS boolean_term','boolean_expression',3,'p_triple_tokens','parser.py',13),
  ('boolean_expression -> numeric_expression EQUALS numeric_term','boolean_expression',3,'p_triple_tokens','parser.py',14),
  ('boolean_expression -> string_expression EQUALS string_term','boolean_expression',3,'p_triple_tokens','parser.py',15),
  ('boolean_expression -> storage_expression EQUALS string_term','boolean_expression',3,'p_triple_tokens','parser.py',16),
  ('boolean_expression -> storage_expression EQUALS numeric_expression','boolean_expression',3,'p_triple_tokens','parser.py',17),
  ('boolean_expression -> approves_expression EQUALS boolean_term','boolean_expression',3,'p_triple_tokens','parser.py',18),
  ('boolean_expression -> gtxn_term EQUALS numeric_expression','boolean_expression',3,'p_triple_tokens','parser.py',19),
  ('boolean_expression -> gtxn_term EQUALS string_term','boolean_expression',3,'p_triple_tokens','parser.py',20),
  ('boolean_expression -> storage_expression LESSER numeric_expression','boolean_expression',3,'p_triple_tokens','parser.py',21),
  ('boolean_expression -> storage_expression GREATER numeric_expression','boolean_expression',3,'p_triple_tokens','parser.py',22),
  ('boolean_expression -> storage_expression LESSER_OR_EQUALS numeric_expression','boolean_expression',3,'p_triple_tokens','parser.py',23),
  ('boolean_expression -> storage_expression GREATER_OR_EQUALS numeric_expression','boolean_expression',3,'p_triple_tokens','parser.py',24),
  ('boolean_expression -> numeric_expression LESSER numeric_term','boolean_expression',3,'p_triple_tokens','parser.py',25),
  ('boolean_expression -> numeric_expression LESSER_OR_EQUALS numeric_term','boolean_expression',3,'p_triple_tokens','parser.py',26),
  ('boolean_expression -> numeric_expression GREATER numeric_term','boolean_expression',3,'p_triple_tokens','parser.py',27),
  ('boolean_expression -> numeric_expression GREATER_OR_EQUALS numeric_term','boolean_expression',3,'p_triple_tokens','parser.py',28),
  ('numeric_expression -> numeric_expression PLUS numeric_term','numeric_expression',3,'p_triple_tokens','parser.py',29),
  ('numeric_expression -> numeric_expression MINUS numeric_term','numeric_expression',3,'p_triple_tokens','parser.py',30),
  ('numeric_term -> numeric_term TIMES numeric_factor','numeric_term',3,'p_triple_tokens','parser.py',31),
  ('numeric_term -> numeric_term DIVIDE numeric_factor','numeric_term',3,'p_triple_tokens','parser.py',32),
  ('numeric_factor -> LPAREN numeric_expression RPAREN','numeric_factor',3,'p_triple_tokens','parser.py',33),
  ('boolean_factor -> LPAREN boolean_expression RPAREN','boolean_factor',3,'p_triple_tokens','parser.py',34),
  ('boolean_expression -> boolean_term','boolean_expression',1,'p_unary_tokens','parser.py',40),
  ('boolean_term -> boolean_factor','boolean_term',1,'p_unary_tokens','parser.py',41),
  ('boolean_factor -> BOOL','boolean_factor',1,'p_unary_tokens','parser.py',42),
  ('numeric_expression -> numeric_term','numeric_expression',1,'p_unary_tokens','parser.py',43),
  ('numeric_term -> numeric_factor','numeric_term',1,'p_unary_tokens','parser.py',44),
  ('numeric_factor -> NUMBER','numeric_factor',1,'p_unary_tokens','parser.py',45),
  ('string_expression -> string_term','string_expression',1,'p_unary_tokens','parser.py',46),
  ('string_term -> string_factor','string_term',1,'p_unary_tokens','parser.py',47),
  ('storage_expression -> storage_term','storage_expression',1,'p_unary_tokens','parser.py',48),
  ('approves_expression -> approves_term','approves_expression',1,'p_unary_tokens','parser.py',49),
  ('approves_term -> approves_factor','approves_term',1,'p_unary_tokens','parser.py',50),
  ('approves_factor -> APPROVES','approves_factor',1,'p_unary_tokens','parser.py',51),
  ('string_factor -> QUOTE STRING QUOTE','string_factor',3,'p_string_address_factor','parser.py',58),
  ('string_factor -> DOUBLE_QUOTE STRING DOUBLE_QUOTE','string_factor',3,'p_string_address_factor','parser.py',59),
  ('address_factor -> QUOTE ADDRESS QUOTE','address_factor',3,'p_string_address_factor','parser.py',60),
  ('address_factor -> DOUBLE_QUOTE ADDRESS DOUBLE_QUOTE','address_factor',3,'p_string_address_factor','parser.py',61),
  ('storage_term -> GLOBAL LBRACKET numeric_factor RBRACKET','storage_term',4,'p_global_storage_term','parser.py',67),
  ('storage_term -> GLOBAL LBRACKET string_factor RBRACKET','storage_term',4,'p_global_storage_term','parser.py',68),
  ('storage_term -> LOCAL LBRACKET address_factor RBRACKET LBRACKET RBRACKET','storage_term',6,'p_local_storage_term','parser.py',74),
  ('storage_term -> LOCAL LBRACKET address_factor RBRACKET LBRACKET string_factor RBRACKET','storage_term',7,'p_local_storage_term','parser.py',75),
  ('gtxn_term -> GROUP_TXN LBRACKET numeric_factor RBRACKET DOT txn_field_factor','gtxn_term',6,'p_group_transaction_field_term','parser.py',82),
  ('gtxn_term -> GROUP_TXN LBRACKET numeric_factor RBRACKET DOT txna_field_factor LBRACKET numeric_factor RBRACKET','gtxn_term',9,'p_group_transaction_array_field_term','parser.py',88),
  ('gtxn_term -> txn_field_factor','gtxn_term',1,'p_txn_field_term','parser.py',94),
  ('gtxn_term -> txna_field_factor LBRACKET numeric_factor RBRACKET','gtxn_term',4,'p_txna_field_term','parser.py',100),
  ('txn_field_factor -> TXN_FIELD','txn_field_factor',1,'p_txn_field_factor','parser.py',106),
  ('txna_field_factor -> TXNA_FIELD','txna_field_factor',1,'p_txna_field_factor','parser.py',112),
]
