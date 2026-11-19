from datetime import datetime
from typing import Any, Dict, Optional
from pydantic import BaseModel, Field


class VerifyObservationInput(BaseModel):
    observation_id: int
    user_id: int
    celestial_object_id: str
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    observed_at: datetime


class VerificationResultResponse(BaseModel):
    id: int
    observation_id: int
    is_valid: bool
    status: str
    score: float
    reasons: str
    details: Optional[Dict[str, Any]] = None
    verified_at: datetime

    class Config:
        from_attributes = True


class VerificationRuleResponse(BaseModel):
    id: int
    rule_name: str
    description: str
    threshold_value: float
    is_active: bool

    class Config:
        from_attributes = True
