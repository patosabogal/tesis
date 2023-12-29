import unittest
from assertions.syntax import Constant


class TestOperations(unittest.TestCase):
    def test_construct_equals(self):
        self.assertTrue(True)


class TestConstants(unittest.TestCase):
    def test_construct_numeric_constant(self):
        numeric_value = 123
        const = Constant(numeric_value)
        self.assertEqual(const.value, numeric_value)

    def test_construct_boolean_constant(self):
        boolean_value = True
        const = Constant(boolean_value)
        self.assertEqual(const.value, boolean_value)


if __name__ == '__main__':
    runner = unittest.TextTestRunner()
    runner.run(unittest.TestSuite())
