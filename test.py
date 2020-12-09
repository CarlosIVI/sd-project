import unittest
import app


class TestApp(unittest.TestCase):
    
    def test_health(self):
        test1 = health()
        self.assertEquals(test1,'Microservice a is ready!')

if __name__ == "__main__":
    unittest.main()