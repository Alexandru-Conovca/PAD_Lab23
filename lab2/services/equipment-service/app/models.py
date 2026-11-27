from datetime import datetime, timezone
from sqlalchemy import Boolean, Column, DateTime, Integer, String, Text

from .database import Base


def utcnow():
    return datetime.now(timezone.utc)


class Telescope(Base):
    __tablename__ = "telescopes"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    name = Column(String(150), nullable=False)
    aperture = Column(Integer, nullable=False)  # in millimeters, e.g. 130
    focal_length = Column(Integer, nullable=False)  # in millimeters, e.g. 900
    mount_type = Column(String(100), nullable=False)  # Equatorial, Alt-Az, Dobsonian
    is_active = Column(Boolean, default=False, nullable=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)
    updated_at = Column(DateTime(timezone=True), default=utcnow, onupdate=utcnow, nullable=False)

    @property
    def focal_ratio(self) -> float:
        if self.aperture and self.aperture > 0:
            return round(self.focal_length / self.aperture, 2)
        return 0.0
