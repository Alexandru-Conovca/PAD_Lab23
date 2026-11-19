from datetime import datetime, timezone
from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from .database import Base


def utcnow():
    return datetime.now(timezone.utc)


class VerificationRule(Base):
    __tablename__ = "verification_rules"

    id = Column(Integer, primary_key=True, index=True)
    rule_name = Column(String(100), unique=True, nullable=False)
    description = Column(Text, nullable=False)
    threshold_value = Column(Float, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)


class VerificationRequest(Base):
    __tablename__ = "verification_requests"

    id = Column(Integer, primary_key=True, index=True)
    observation_id = Column(Integer, nullable=False, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    celestial_object_id = Column(String(50), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    observed_at = Column(DateTime(timezone=True), nullable=False)
    status = Column(String(50), default="PROCESSING", nullable=False)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    result = relationship("VerificationResult", back_populates="request", uselist=False, cascade="all, delete-orphan")


class VerificationResult(Base):
    __tablename__ = "verification_results"

    id = Column(Integer, primary_key=True, index=True)
    request_id = Column(Integer, ForeignKey("verification_requests.id", ondelete="CASCADE"), nullable=False, index=True)
    observation_id = Column(Integer, nullable=False, index=True)
    is_valid = Column(Boolean, nullable=False)
    status = Column(String(50), nullable=False)  # VERIFIED or REJECTED
    score = Column(Float, nullable=False)  # 0.0 to 1.0
    details_json = Column(Text, nullable=True)  # JSON string of breakdown
    reasons = Column(Text, nullable=False)
    verified_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    request = relationship("VerificationRequest", back_populates="result")
