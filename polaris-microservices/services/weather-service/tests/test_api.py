import pytest
from fastapi.testclient import TestClient

from app.main import app

@pytest.fixture(scope="module")
def client():
    with TestClient(app) as test_client:
        yield test_client


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["service"] == "weather-service"


def test_conditions_endpoint(client):
    response = client.get("/api/weather/conditions?latitude=47.01&longitude=28.86")
    assert response.status_code == 200
    data = response.json()
    assert "suitability_score" in data
    assert "rating" in data
    assert "is_suitable" in data
