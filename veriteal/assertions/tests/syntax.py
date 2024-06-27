import unittest
from assertions.syntax import Assertions


class TestAssertions(unittest.TestCase):
    def test_constructor(self):
        method_name = "method"
        assertions = ["1 == 1"]
        new_assertion = Assertions(method_name, assertions)
        self.assertEqual(new_assertion.method_name, method_name)
        self.assertEqual(len(new_assertion.assertions), 1)


if __name__ == "__main__":
    runner = unittest.TextTestRunner()
    runner.run(unittest.TestSuite())
