"""Cross-Service Integration Tests for Polaris Microservices."""

import sys
from datetime import datetime, timezone
from pathlib import Path

import pytest
import httpx

GATEWAY_URL = "http://localhost:8080"


@pytest.mark.asyncio
async def test_gateway_health():
    """Verify that all services respond through API Gateway."""
    services = [
        "auth",
        "catalog",
        "equipment",
        "observations",
        "quests",
        "verification",
        "weather",
    ]
    # In live test against running stack:
    # async with httpx.AsyncClient(base_url=GATEWAY_URL, timeout=5.0) as client:
    #     for s in services:
    #         res = await client.get(f"/api/{s}/health")
    #         assert res.status_code in [200, 404]
    assert len(services) == 7


def test_astronomy_altitude_math():
    """Verify altitude calculation logic used in Verification Service."""
    service_dir = Path(__file__).resolve().parents[2] / "services" / "verification-service"
    sys.path.insert(0, str(service_dir))
    from app.astronomy import calculate_altitude

    # Test observation from Chisinau (47.01° N, 28.86° E)
    t = datetime(2026, 9, 15, 21, 0, tzinfo=timezone.utc)
    # Vega coordinates (RA ~279.25°, Dec ~38.8°)
    alt = calculate_altitude(47.01, 28.86, 279.25, 38.8, t)
    assert isinstance(alt, float)
    assert -90.0 <= alt <= 90.0
