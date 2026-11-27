from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from .database import get_db
from .schemas import ObservationConditionsResponse, WeatherCurrentResponse, WeatherForecastResponse
from .services import WeatherService

router = APIRouter(prefix="/api/weather", tags=["Weather"])


@router.get("/current", response_model=WeatherCurrentResponse)
async def get_current_weather(
    latitude: float = Query(..., ge=-90, le=90, description="Observer latitude in decimal degrees"),
    longitude: float = Query(..., ge=-180, le=180, description="Observer longitude in decimal degrees"),
    db: Session = Depends(get_db),
):
    """Retrieve current meteorological conditions at the observer location."""
    return await WeatherService.get_current_weather(latitude, longitude, db)


@router.get("/forecast", response_model=WeatherForecastResponse)
async def get_forecast(
    latitude: float = Query(..., ge=-90, le=90),
    longitude: float = Query(..., ge=-180, le=180),
    hours: int = Query(24, ge=1, le=48, description="Forecast horizon in hours"),
    db: Session = Depends(get_db),
):
    """Retrieve hourly meteorological forecast for stargazing planning."""
    return await WeatherService.get_forecast(latitude, longitude, hours, db)


@router.get("/conditions", response_model=ObservationConditionsResponse)
async def get_conditions(
    latitude: float = Query(..., ge=-90, le=90),
    longitude: float = Query(..., ge=-180, le=180),
    timestamp: Optional[datetime] = Query(None, description="Observation timestamp to evaluate"),
    db: Session = Depends(get_db),
):
    """Assess whether current or requested atmospheric conditions are suitable for astronomy."""
    return await WeatherService.evaluate_conditions(latitude, longitude, timestamp, db)
