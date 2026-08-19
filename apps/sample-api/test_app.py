import unittest

from app import app


class HealthCheckTest(unittest.TestCase):
    def test_healthz(self):
        response = app.test_client().get("/healthz")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json, {"status": "ok"})
