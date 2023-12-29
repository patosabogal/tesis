from dataclasses import dataclass, field
from typing import Union, List, Optional

class BoogieSyntax():
    def __eq__(self, other):
        if isinstance(other, BoogieSyntax) or isinstance(other, str):
            return str(self) == other
        return False

    def __str__(self) -> str:
        return ""


class Type(BoogieSyntax):
    pass


class Int(Type):
    def __str__(self):
        return 'int'


class Bool(Type):
    def __str__(self):
        return 'bool'


@dataclass(eq=False)
class Map(Type):
    keyType: Type
    valueType: Type

    def __str__(self):
        return f'[{self.keyType}] {self.valueType}'


@dataclass(eq=False)
class Variable(BoogieSyntax):
    name: str

    def __str__(self):
        return self.name


@dataclass(eq=False)
class MapVariableAccess(Variable):
    key: Variable

    def __str__(self):
        return f"{self.name}[{self.key}]"

Value = Union[Variable, int]


class Operation(BoogieSyntax):
    pass


class Instruction(BoogieSyntax):
    pass


class Label(Instruction):
    name: str

    def __str__(self):
        return f"{self.name}:\n"


class Jump(Instruction):
    label: Label

    def __str__(self):
        return f"goto {self.label};\n"


class JumpIfZero(Instruction):
    variable: Variable
    zero_label: Label
    not_zero_label: Label

    def __str__(self):
        return f"if({self.variable} == 0) {{" \
               f"goto {self.zero_label};" \
               f"}}"\
               f"else {{"\
               f"goto {self.not_zero_label};"\
               f"}}"


@dataclass(eq=False)
class VariableAssigment(Instruction):
    lhs: Union[Variable, MapVariableAccess]
    rhs: Union[Value, Operation]

    def __str__(self):
        return f"{self.lhs} := {self.rhs};\n"


@dataclass(eq=False)
class Parameter(BoogieSyntax):
    variable: Variable
    type: Type

    def __str__(self):
        return f"{self.variable}: {self.type}"


@dataclass(eq=False)
class VariableDeclaration(BoogieSyntax):
    parameter: Parameter

    def __str__(self):
        return f"var {self.parameter};\n"


@dataclass(eq=False)
class Axiom(BoogieSyntax):
    axiom: str

    def __str__(self):
        return f"axiom {self.axiom};\n"


@dataclass(eq=False)
class Function(BoogieSyntax):
    name: str
    return_type: Type
    parameters: List[Parameter] = field(default_factory=list)
    axioms: List[Axiom] = field(default_factory=list)

    def _function_declaration(self):
        separator = ", "
        parameters = separator.join(map(lambda parameter: str(parameter), self.parameters))
        return f"function {self.name}({parameters}) returns ({self.return_type});\n"

    def _axioms(self):
        separator = ""
        return separator.join(map(lambda axiom: str(axiom), self.axioms))

    def __str__(self):
        return self._function_declaration() + self._axioms()


@dataclass(eq=False)
class Procedure(BoogieSyntax):
    name: str
    return_var: Optional[Parameter] = None
    parameters: List[Parameter] = field(default_factory=list)
    variable_declarations: List[VariableDeclaration] = field(default_factory=list)
    instructions: List[Instruction] = field(default_factory=list)

    def _procedure_declaration(self):
        separator = ", "
        parameters = separator.join(map(str, self.parameters))
        return_string = f" returns ({self.return_var})" if self.return_var is not None else ""
        return f"procedure {self.name}({parameters}){return_string};\n"

    def _implementation_aperture(self):
        separator = ", "
        parameters = separator.join(map(str, self.parameters))
        return_string = f" returns ({self.return_var})" if self.return_var is not None else ""
        return f"implementation {self.name}({parameters}){return_string} {{\n"

    def _implementation_body(self):
        variable_declarations_strings = map(str, self.variable_declarations)
        instructions_strings = map(str, self.instructions)
        return "".join(list(variable_declarations_strings) + list(instructions_strings))

    def _implementation_closure(self):
        return f"}}\n"

    def __str__(self):
        return self._procedure_declaration()\
            + self._implementation_aperture()\
            + self._implementation_body()\
            + self._implementation_closure()


class Boogie(BoogieSyntax):
    global_variables: List[VariableDeclaration] = []
    functions: List[Function] = []
    procedures: List[Procedure] = []

    def __str__(self):
        _globals = map(str, self.global_variables)
        _functions = map(str, self.functions)
        _procedures = map(str, self.procedures)
        separator = ""
        return separator.join(list(_globals) + list(_functions) + list(_procedures))

# TODO: implement more instructions

