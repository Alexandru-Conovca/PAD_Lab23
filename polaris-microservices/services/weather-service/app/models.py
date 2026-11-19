from datetime import datetime, timezone
from sqlalchemy import Column, DateTime, Float, Integer, String, Text

from .database import Base


def utcnow():
    return datetime.now(timezone.utc)


class WeatherForecast(Base):
    __tablename__ = "weather_forecasts"

    id = Column(Integer, primary_key=True, index=True)
    latitude = Column(Float, nullable=False, index=True)
    longitude = Column(Float, nullable=False, index=True)
    recorded_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)
    temperature = Column(Float, nullable=False)  # Celsius
    cloud_cover = Column(Float, nullable=False)  # 0 to 100%
    relative_humidity = Column(Float, nullable=False)  # %
    visibility = Column(Float, nullable=True)  # meters
    wind_speed = Column(Float, nullable=True)  # km/h
    source = Column(String(50), default="open-meteo", nullable=False)


class ObservationConditions(Base):
    __tablename__ = "observation_conditions"

    id = Column(Integer, primary_key=True, index=True)
    latitude = Column(Float, nullable=False, index=True)
    longitude = Column(Float, nullable=False, index=True)
    timestamp = Column(DateTime(timezone=True), default=utcnow, nullable=False)
    cloud_cover = Column(Float, nullable=False)
    suitability_score = Column(Float, nullable=False)  # 0.0 to 1.0
    rating = Column(String(50), nullable=False)  # EXCELLENT, GOOD, FAIR, POOR
    summary = Column(Text, nullable=False)
