from datetime import datetime, timezone
from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import relationship

from .database import Base


def utcnow():
    return datetime.now(timezone.utc)


class ObjectCategory(Base):
    __tablename__ = "object_categories"

    id = Column(String(50), primary_key=True)
    name = Column(String(100), nullable=False)
    description = Column(Text, nullable=True)

    objects = relationship("CelestialObject", back_populates="category_rel")


class CelestialObject(Base):
    __tablename__ = "celestial_objects"

    id = Column(String(50), primary_key=True)
    name = Column(String(150), nullable=False, index=True)
    type = Column(String(50), nullable=False, index=True)  # planet, galaxy, nebula, star
    category_id = Column(String(50), ForeignKey("object_categories.id"), nullable=True)
    description = Column(Text, nullable=False)
    magnitude = Column(Float, nullable=False)
    right_ascension = Column(Float, nullable=False, default=0.0)  # in degrees (0 to 360)
    declination = Column(Float, nullable=False, default=0.0)      # in degrees (-90 to +90)
    coordinates_str = Column(String(100), nullable=False)
    constellation = Column(String(100), nullable=False, index=True)
    is_visible_now = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    category_rel = relationship("ObjectCategory", back_populates="objects")
    favorites = relationship("Favorite", back_populates="celestial_object", cascade="all, delete-orphan")


class Favorite(Base):
    __tablename__ = "favorites"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    object_id = Column(String(50), ForeignKey("celestial_objects.id", ondelete="CASCADE"), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    celestial_object = relationship("CelestialObject", back_populates="favorites")

    __table_args__ = (UniqueConstraint("user_id", "object_id", name="uq_user_object_favorite"),)
