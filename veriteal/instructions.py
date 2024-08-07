from dataclasses import dataclass
from typing import Dict, Type

from veriteal.constants import (
    CURRENT_TRANSACTION,
    label_name,
    local_variable_name,
    phi_variable_name,
    scratch_slot_variable_name,
    transaction_field_access,
    transaction_array_field_access,
    variable_assigment,
    global_map_access,
    local_map_access,
    RETURN_VARIABLE_NAME,
    EXIT_LABEL,
    transaction_fields,
    transaction_array_fields,
    global_fields,
    type_enums,
)
from veriteal.methods import string_to_int
from veriteal.tealift import Instruction, BasicBlock


@dataclass
class ParsedInstruction:
    instruction: Instruction
    instruction_index: int
    basic_block: BasicBlock
    basic_block_index: int

    def _get_variable_consumed(self, consumed_variable_index: int):
        variable: str
        consumed_variable = self.instruction.consumes[consumed_variable_index]
        if consumed_variable >= 0:
            variable = local_variable_name(consumed_variable)
        else:
            variable = phi_variable_name(
                self.basic_block_index, self.instruction_index, consumed_variable_index
            )
        return variable

    @staticmethod
    def operator() -> str:
        return ""

    @staticmethod
    def returns_value() -> bool:
        return False

    def calls(self) -> bool:
        return False

    def to_boogie(self) -> str:
        return ""


def binary_operation_builder(
    _operator: str, boogie_symbol: str, _is_boolean: bool
) -> Type[ParsedInstruction]:
    class BinaryOperation(ParsedInstruction):
        is_boolean = _is_boolean

        @staticmethod
        def operator():
            return _operator

        @staticmethod
        def returns_value():
            return True

        @property
        def lhs(self):
            return self._get_variable_consumed(1)

        @property
        def rhs(self):
            return self._get_variable_consumed(0)

        def to_boogie(self):
            string = f"{self.lhs} {boogie_symbol} {self.rhs}"
            if self.is_boolean:
                string = f"to_int({string})"
            return string

    return BinaryOperation

def binary_boolean_operation_builder(
    _operator: str, boogie_symbol: str
) -> Type[ParsedInstruction]:
    class BinaryOperation(ParsedInstruction):
        @staticmethod
        def operator():
            return _operator

        @staticmethod
        def returns_value():
            return True

        @property
        def lhs(self):
            return self._get_variable_consumed(1)

        @property
        def rhs(self):
            return self._get_variable_consumed(0)

        def to_boogie(self):
            string = f"to_int(to_bool({self.lhs}) {boogie_symbol} to_bool({self.rhs}))"
            return string

    return BinaryOperation




Add = binary_operation_builder("add", "+", False)
And = binary_boolean_operation_builder("and", "&&")
Or = binary_boolean_operation_builder("or", "||")
Equals = binary_operation_builder("eq", "==", True)
NotEquals = binary_operation_builder("ne", "!=", True)
LesserThan = binary_operation_builder("lt", "<", True)
GreaterThan = binary_operation_builder("gt", ">", True)
GreaterThanOrEquals = binary_operation_builder("ge", ">=", True)
LesserThanOrEquals = binary_operation_builder("le", "<=", True)


@dataclass
class Const(ParsedInstruction):
    @staticmethod
    def operator():
        return "const"

    @staticmethod
    def returns_value():
        return True

    @property
    def returned_variable(self):
        if self.instruction.arguments[1] in type_enums.keys():
            return type_enums[self.instruction.arguments[1]]
        if self.instruction.arguments[0] == "uint64":
            return self.instruction.arguments[1]
        if self.instruction.arguments[0] == "[]byte":
            return string_to_int(self.instruction.arguments[1].replace('\\"', ""))

    def to_boogie(self):
        return f"{self.returned_variable}"


@dataclass
class ExtConst(ParsedInstruction):
    @staticmethod
    def operator():
        return "ext_const"

    @staticmethod
    def returns_value():
        return True

    def calls(self):
        return self.instruction.arguments[1] in transaction_fields

    @property
    def returned_variable(self):
        # If its a transaction field access, aka, txn.
        if self.instruction.arguments[1] in transaction_fields:
            return transaction_field_access(
                self.instruction.arguments[1], CURRENT_TRANSACTION
            )
        elif self.instruction.arguments[1] in global_fields:
            return self.instruction.arguments[1]

    def to_boogie(self):
        return f"{self.returned_variable}"


@dataclass
class ExtConstArray(ParsedInstruction):
    @staticmethod
    def operator():
        return "ext_const_array"

    @staticmethod
    def returns_value():
        return True

    def calls(self):
        return True

    @property
    def returned_variable(self):
        # Its a group transaction field access, aka, gtxn.
        if self.instruction.arguments[1] in transaction_fields:
            return transaction_field_access(
                self.instruction.arguments[1],
                self._get_variable_consumed(0),
            )
        else:
            # Its a transaction array field access, aka, txna.
            return transaction_array_field_access(
                self.instruction.arguments[1],
                CURRENT_TRANSACTION,
                self._get_variable_consumed(0),
            )

    def to_boogie(self):
        return f"{self.returned_variable}"


@dataclass
class ExtConstArrayArray(ParsedInstruction):
    @staticmethod
    def operator():
        return "ext_const_array_array"

    @staticmethod
    def returns_value():
        return True

    def calls(self):
        return True

    @property
    def returned_variable(self):
        # Its a group transaction array field access, aka, gtxna.
        if self.instruction.arguments[1] in transaction_array_fields:
            return transaction_array_field_access(
                self.instruction.arguments[1],
                self._get_variable_consumed(0),
                self._get_variable_consumed(1),
            )

    def to_boogie(self):
        return f"{self.returned_variable}"


@dataclass
class Assert(ParsedInstruction):
    @staticmethod
    def operator():
        return "assert"

    @staticmethod
    def returns_value():
        return False

    def to_boogie(self):
        return f"assume {self._get_variable_consumed(0)} != 0;\n"


@dataclass
class Jump(ParsedInstruction):
    @staticmethod
    def operator():
        return "jmp"

    @staticmethod
    def returns_value():
        return False

    @property
    def label(self):
        return label_name(self.basic_block.outgoing_edges[0])

    def to_boogie(self):
        return f"goto {self.label};\n"


@dataclass
class SwitchOnZero(ParsedInstruction):
    @staticmethod
    def operator():
        return "switch-on-zero"

    @staticmethod
    def returns_value():
        return False

    @property
    def condition(self):
        return self._get_variable_consumed(0)

    @property
    def true_path_label(self):
        return label_name(self.basic_block.outgoing_edges[0])

    @property
    def false_path_label(self):
        return label_name(self.basic_block.outgoing_edges[1])

    def to_boogie(self):
        return f"""if({self.condition} == 0) {{
    goto {self.true_path_label};
}}
else {{
    goto {self.false_path_label};
}}
"""


@dataclass
class Select(ParsedInstruction):
    @staticmethod
    def operator():
        return "select"

    @staticmethod
    def returns_value():
        return True

    def calls(self):
        return True

    def to_boogie(self):
        condition = self._get_variable_consumed(0)
        on_zero = self._get_variable_consumed(1)
        on_not_zero = self._get_variable_consumed(2)
        return f"select({condition},{on_zero},{on_not_zero})"


@dataclass
class Exit(ParsedInstruction):
    @staticmethod
    def operator():
        return "exit"

    @staticmethod
    def returns_value():
        return False

    # ASK_MEGA: Can there be another exit?
    def to_boogie(self):
        return (
            variable_assigment(
                RETURN_VARIABLE_NAME, self._get_variable_consumed(0)
            )
            + f"goto {EXIT_LABEL};\n"
        )


@dataclass
class LoadScratch(ParsedInstruction):
    @staticmethod
    def operator():
        return "load_scratch"

    @staticmethod
    def returns_value():
        return True

    @property
    def returned_variable(self):
        return scratch_slot_variable_name(self.instruction.arguments[0])

    def to_boogie(self):
        return f"{self.returned_variable}"


@dataclass
class StoreScratch(ParsedInstruction):
    @staticmethod
    def operator():
        return "store_scratch"

    @staticmethod
    def returns_value():
        return False

    def to_boogie(self):
        return f"{variable_assigment(scratch_slot_variable_name(self.instruction.arguments[0]), self._get_variable_consumed(0))}"


@dataclass
class StoreGlobal(ParsedInstruction):
    @staticmethod
    def operator():
        return "store_global"

    @staticmethod
    def returns_value():
        return False

    def to_boogie(self):
        return f"{variable_assigment(global_map_access(self._get_variable_consumed(0)), self._get_variable_consumed(1))}"


@dataclass
class LoadGlobal(ParsedInstruction):
    @staticmethod
    def operator():
        return "load_global"

    @staticmethod
    def returns_value():
        return True

    def to_boogie(self):
        return f"{global_map_access(self._get_variable_consumed(0))}"


@dataclass
class StoreLocal(ParsedInstruction):
    @staticmethod
    def operator():
        return "store_local"

    @staticmethod
    def returns_value():
        return False

    def to_boogie(self):
        return f"{variable_assigment(local_map_access(self._get_variable_consumed(0), self._get_variable_consumed(1)), self._get_variable_consumed(2))}"


@dataclass
class LoadLocal(ParsedInstruction):
    @staticmethod
    def operator():
        return "load_local"

    @staticmethod
    def returns_value():
        return True

    def to_boogie(self):
        return f"{local_map_access(self._get_variable_consumed(0), self._get_variable_consumed(1))}"


@dataclass
class DivModWHiQuo(ParsedInstruction):
    @staticmethod
    def operator():
        return "divmodw_hi_q"

    @staticmethod
    def returns_value():
        return True

    def to_boogie(self):
        return f"{local_map_access(self._get_variable_consumed(0), self._get_variable_consumed(1))}"


# @dataclass
# class DivModWLoRem(ParsedInstruction):
#    @staticmethod
#    def operator():
#        return 'divmodw_lo_rem'
#
#    @staticmethod
#    def returns_value():
#        return True
#
#    def to_boogie(self):
#        return f"{self._get_variable(self.instruction.consumes[0])}*340282366920938463463374607431768211456+{self._get_variable(self.instruction.consumes[1])}"

operations = [
    Add,
    Equals,
    NotEquals,
    Select,
    Assert,
    And,
    Const,
    Exit,
    Jump,
    LesserThan,
    LesserThanOrEquals,
    GreaterThan,
    GreaterThanOrEquals,
    SwitchOnZero,
    StoreScratch,
    LoadScratch,
    StoreGlobal,
    LoadGlobal,
    StoreLocal,
    LoadLocal,
    ExtConst,
    ExtConstArray,
    ExtConstArrayArray,
]

operation_class: Dict[str, Type[ParsedInstruction]] = {}
for operation in operations:
    operation_class[operation.operator()] = operation
