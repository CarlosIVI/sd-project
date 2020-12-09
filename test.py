import unittest
import app as flask_app


class TestApp(unittest.TestCase):
    
    def test_health(self):
        test1 = flask_app.health()
        self.assertEqual(test1,'Microservice a is ready!')

if __name__ == "__main__":
    unittest.main()
