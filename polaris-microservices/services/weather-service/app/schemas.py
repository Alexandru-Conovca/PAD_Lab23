from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class WeatherCurrentResponse(BaseModel):
    latitude: float
    longitude: float
    timestamp: datetime
    temperature: float
    cloud_cover: float
    relative_humidity: float
    visibility: Optional[float] = None
    wind_speed: Optional[float] = None
    source: str


class HourlyForecastItem(BaseModel):
    time: str
    temperature: float
    cloud_cover: float
    humidity: float


class WeatherForecastResponse(BaseModel):
    latitude: float
    longitude: float
    source: str
    hourly: List[HourlyForecastItem]


class ObservationConditionsResponse(BaseModel):
    latitude: float
    longitude: float
    timestamp: datetime
    cloud_cover: float
    suitability_score: float = Field(..., ge=0.0, le=1.0)
    rating: str  # EXCELLENT, GOOD, FAIR, POOR
    is_suitable: bool
    summary: str
