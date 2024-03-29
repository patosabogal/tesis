from dataclasses import dataclass
from typing import Dict, Type

from constants import label_name, local_variable_name, phi_variable_name, scratch_slot_variable_name, \
    variable_assigment, global_map_access, local_map_access, RETURN_VARIABLE_NAME, EXIT_LABEL
from methods import string_to_int
from tealift import Instruction, BasicBlock


@dataclass
class ParsedInstruction:
    instruction: Instruction
    instruction_index: int
    basic_block: BasicBlock
    basic_block_index: int

    def _get_variable(self, consumed_variable_index):
        variable: str
        if consumed_variable_index >= 0:
            variable = local_variable_name(consumed_variable_index)
        else:
            variable = phi_variable_name(self.basic_block_index, abs(consumed_variable_index) - 1)
        return variable

    @staticmethod
    def operator() -> str:
        return ""

    @staticmethod
    def returns_value() -> bool:
        return False

    def to_boogie(self) -> str:
        return ""


def binary_operation_builder(_operator: str, boogie_symbol: str,_is_boolean: bool) -> Type[ParsedInstruction]:
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
            return self._get_variable(self.instruction.consumes[0])

        @property
        def rhs(self):
            return self._get_variable(self.instruction.consumes[1])

        def to_boogie(self):
            string = f"{self.lhs} {boogie_symbol} {self.rhs}"
            if self.is_boolean:
                string = f"to_int({string})"
            return string

    return BinaryOperation


Add = binary_operation_builder('add', '+' ,False)
And = binary_operation_builder('and', '&&',True)
LowerThan = binary_operation_builder('lt', '<',True)


@dataclass
class Const(ParsedInstruction):
    @staticmethod
    def operator():
        return 'const'

    @staticmethod
    def returns_value():
        return True

    @property
    def returned_variable(self):
        if self.instruction.arguments[0] == 'uint64':
            return self.instruction.arguments[1]
        if self.instruction.arguments[0] == '[]byte':
            return string_to_int(self.instruction.arguments[1].replace("\\\"",""))

    def to_boogie(self):
        return f"{self.returned_variable}"


@dataclass
class Jump(ParsedInstruction):
    @staticmethod
    def operator():
        return 'jmp'

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
        return 'switch-on-zero'

    @staticmethod
    def returns_value():
        return False

    @property
    def condition(self):
        return self._get_variable(self.instruction.consumes[0])

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
class Exit(ParsedInstruction):
    @staticmethod
    def operator():
        return 'exit'

    @staticmethod
    def returns_value():
        return False

    # ASK_MEGA: Can there be another exit?
    def to_boogie(self):
        return variable_assigment(RETURN_VARIABLE_NAME, self._get_variable(self.instruction.consumes[0]))+ f"goto {EXIT_LABEL};\n"



@dataclass
class LoadScratch(ParsedInstruction):
    @staticmethod
    def operator():
        return 'load_scratch'

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
        return 'store_scratch'

    @staticmethod
    def returns_value():
        return False

    def to_boogie(self):
        return f"{variable_assigment(scratch_slot_variable_name(self.instruction.arguments[0]), self._get_variable(self.instruction.consumes[0]))}"

@dataclass
class StoreGlobal(ParsedInstruction):
    @staticmethod
    def operator():
        return 'store_global'

    @staticmethod
    def returns_value():
        return False

    def to_boogie(self):
        return f"{variable_assigment(global_map_access(self._get_variable(self.instruction.consumes[0])), self._get_variable(self.instruction.consumes[1]))}"


@dataclass
class LoadGlobal(ParsedInstruction):
    @staticmethod
    def operator():
        return 'load_global'

    @staticmethod
    def returns_value():
        return True

    def to_boogie(self):
        return f"{global_map_access(self._get_variable(self.instruction.consumes[0]))}"


@dataclass
class StoreLocal(ParsedInstruction):
    @staticmethod
    def operator():
        return 'store_local'

    @staticmethod
    def returns_value():
        return False

    def to_boogie(self):
        return f"{variable_assigment(local_map_access(self._get_variable(self.instruction.consumes[0]), self._get_variable(self.instruction.consumes[1])), self._get_variable(self.instruction.consumes[2]))}"


@dataclass
class LoadLocal(ParsedInstruction):
    @staticmethod
    def operator():
        return 'load_local'

    @staticmethod
    def returns_value():
        return True

    def to_boogie(self):
        return f"{local_map_access(self._get_variable(self.instruction.consumes[0]), self._get_variable(self.instruction.consumes[1]))}"


operation_class: Dict[str, Type[ParsedInstruction]] = {
    Add.operator(): Add,
    And.operator(): And,
    Const.operator(): Const,
    Exit.operator(): Exit,
    Jump.operator(): Jump,
    LowerThan.operator(): LowerThan,
    SwitchOnZero.operator(): SwitchOnZero,
    StoreScratch.operator(): StoreScratch,
    LoadScratch.operator(): LoadScratch,
    StoreGlobal.operator(): StoreGlobal,
    LoadGlobal.operator(): LoadGlobal,
    StoreLocal.operator(): StoreLocal,
    LoadLocal.operator(): LoadLocal,
}
