from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["service"] == "verification-service"


def test_rules():
    response = client.get("/api/verification/rules")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
