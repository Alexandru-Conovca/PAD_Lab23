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
    assert data["service"] == "catalog-service"


def test_categories(client):
    response = client.get("/api/catalog/categories")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
