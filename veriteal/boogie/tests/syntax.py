import unittest
from boogie.syntax import *


class TestType(unittest.TestCase):
    def test_int(self):
        self.assertEqual(Int(), "int")

    def test_bool(self):
        self.assertEqual(Bool(), "bool")

    def test_map_int_int(self):
        self.assertEqual(Map(Int(), Int()), "[int] int")

    def test_map_int_map_int_int(self):
        self.assertEqual(Map(Int(), Map(Int(), Int())), "[int] [int] int")


class TestVariable(unittest.TestCase):
    def test_variable(self):
        var_name = "var"
        self.assertEqual(Variable(var_name), var_name)


class TestMapVariableAccess(unittest.TestCase):
    def test_base_map_access(self):
        map_var = Variable("map_var")
        key_var = Variable("key_var")
        self.assertEqual(MapVariableAccess(map_var, key_var), f"{map_var}[{key_var}]")

    def test_recursive_map_access(self):
        base_map_var = Variable("base_map_var")
        base_map_key = Variable("base_map_key")
        map_access = MapVariableAccess(base_map_var, base_map_key)
        map_key = Variable("key_var")
        self.assertEqual(
            MapVariableAccess(map_access, map_key),
            f"{base_map_var}[{base_map_key}][{map_key}]",
        )


class TestVariableAssigment(unittest.TestCase):
    def test_variable_assignment(self):
        lhs = Variable("lhs")
        rhs = Variable("rhs")
        self.assertEqual(VariableAssigment(lhs, rhs), f"{lhs} := {rhs};\n")


class TestParameter(unittest.TestCase):
    def test_parameters(self):
        var_a = Variable("a")
        var_type = Int()
        parameter = Parameter(var_a, var_type)
        self.assertEqual(parameter, f"{var_a}: {var_type}")


class TestVariableDefinition(unittest.TestCase):
    def test_variable_definition(self):
        var_a = Variable("a")
        var_type = Int()
        parameter = Parameter(var_a, var_type)
        self.assertEqual(VariableDeclaration(parameter), f"var {parameter};\n")


class TestAxioms(unittest.TestCase):
    def test_axiom(self):
        axiom = "a == b"
        self.assertEqual(Axiom(axiom), f"axiom {axiom};\n")


class TestFunction(unittest.TestCase):
    func_name = "not"
    func_return_type = Bool()
    var_a = Variable("a")
    parameters = [Parameter(var_a, Bool())]
    axioms = [Axiom("not(true) == false"), Axiom("not(false) == true")]

    def test_function_without_parameters_nor_axioms(self):
        self.assertEqual(
            Function(self.func_name, self.func_return_type),
            f"function {self.func_name}() " f"returns ({self.func_return_type});\n",
        )

    def test_function_without_parameters(self):
        self.assertEqual(
            Function(self.func_name, self.func_return_type, axioms=self.axioms),
            f"function {self.func_name}() returns ({self.func_return_type});\n"
            + "".join(list(map(str, self.axioms))),
        )

    def test_function(self):
        self.assertEqual(
            Function(
                self.func_name,
                self.func_return_type,
                axioms=self.axioms,
                parameters=self.parameters,
            ),
            f"function {self.func_name}({', '.join(list(map(str, self.parameters)))}) "
            f"returns ({self.func_return_type});\n"
            + "".join(list(map(str, self.axioms))),
        )


class TestProcedure(unittest.TestCase):
    procedure_name = "not"
    var_a = Variable("a")
    var_b = Variable("b")
    var_c = Variable("c")
    procedure_return_variable = Parameter(var_c, Bool())
    parameters = [Parameter(var_a, Bool())]
    variable_declarations = [VariableDeclaration(Parameter(var_b, Bool()))]
    instructions = [VariableAssigment(var_b, var_a), VariableAssigment(var_c, var_b)]

    def test_procedure_empty_procedure(self):
        self.assertEqual(
            str(Procedure(self.procedure_name)),
            f"procedure {self.procedure_name}();\nimplementation {self.procedure_name}() {{\n}}\n",
        )

    def test_procedure_with_return_var(self):
        self.assertEqual(
            Procedure(self.procedure_name, self.procedure_return_variable),
            f"procedure {self.procedure_name}() returns ({self.procedure_return_variable});\n"
            f"implementation {self.procedure_name}() returns ({self.procedure_return_variable}) {{\n}}\n",
        )

    def test_procedure_with_parameters(self):
        parameters_string = ", ".join(list(map(str, self.parameters)))
        self.assertEqual(
            Procedure(self.procedure_name, parameters=self.parameters),
            f"procedure {self.procedure_name}({parameters_string});\n"
            f"implementation {self.procedure_name}({parameters_string}) {{\n}}\n",
        )

    def test_procedure_with_variable_declarations(self):
        var_declarations_string = "\n".join(list(map(str, self.variable_declarations)))
        self.assertEqual(
            Procedure(
                self.procedure_name, variable_declarations=self.variable_declarations
            ),
            f"procedure {self.procedure_name}();\n"
            f"implementation {self.procedure_name}() {{\n"
            f"{var_declarations_string}"
            f"}}\n",
        )

    def test_full_procedure(self):
        var_declarations_string = "\n".join(list(map(str, self.variable_declarations)))
        parameters_string = ", ".join(list(map(str, self.parameters)))
        instructions_string = "".join(list(map(str, self.instructions)))
        self.assertEqual(
            Procedure(
                self.procedure_name,
                variable_declarations=self.variable_declarations,
                return_var=self.procedure_return_variable,
                instructions=self.instructions,
                parameters=self.parameters,
            ),
            f"procedure {self.procedure_name}({parameters_string}) "
            f"returns ({self.procedure_return_variable});\n"
            f"implementation {self.procedure_name}({parameters_string}) "
            f"returns ({self.procedure_return_variable}) {{\n"
            f"{var_declarations_string}"
            f"{instructions_string}"
            f"}}\n",
        )


if __name__ == "__main__":
    runner = unittest.TextTestRunner()
    runner.run(unittest.TestSuite())
