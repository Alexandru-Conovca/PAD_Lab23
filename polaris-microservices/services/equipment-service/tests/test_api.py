from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["service"] == "equipment-service"


def test_unauthorized_equipment_list():
    response = client.get("/api/equipment")
    assert response.status_code == 401
