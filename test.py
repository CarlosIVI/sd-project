import unittest
import app as flask_app
import os

class TestApp(unittest.TestCase):

    def test_health(self):
        test1 = flask_app.health()
        self.assertEqual(test1,'Microservice a is ready!')
        print('OK')

if __name__ == "__main__":
    unittest.main()
