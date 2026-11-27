from datetime import datetime, timezone
from sqlalchemy import Column, DateTime, Float, Integer, String, Text

from .database import Base


def utcnow():
    return datetime.now(timezone.utc)


class Observation(Base):
    __tablename__ = "observations"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    celestial_object_id = Column(String(50), nullable=False, index=True)
    telescope_id = Column(Integer, nullable=True)
    quest_id = Column(String(50), nullable=True, index=True)
    observed_at = Column(DateTime(timezone=True), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    location_name = Column(String(150), nullable=True)
    status = Column(String(50), default="PENDING", nullable=False, index=True)  # PENDING, VERIFIED, REJECTED
    notes = Column(Text, nullable=True)
    verification_score = Column(Float, nullable=True)
    verification_reason = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=utcnow, onupdate=utcnow, nullable=False)
