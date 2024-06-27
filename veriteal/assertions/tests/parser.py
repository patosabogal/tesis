import unittest
from assertions.parser import parser
from methods import string_to_int


class TestParser(unittest.TestCase):
    def test_parse_booleans(self):
        result_true = parser.parse("true")
        result_false = parser.parse("false")
        self.assertEqual(result_true, "true")
        self.assertEqual(result_false, "false")

    def test_parse_global(self):
        result_global = parser.parse("Global[0] == 0")
        self.assertEqual(result_global, "Global[0] == 0")
        result_global = parser.parse("Global[1] == 'string'")
        self.assertEqual(result_global, f"""Global[1] == {string_to_int("'string'")}""")


if __name__ == "__main__":
    runner = unittest.TextTestRunner()
    runner.run(unittest.TestSuite())
