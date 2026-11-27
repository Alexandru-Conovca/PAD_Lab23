from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class ObservationCreateRequest(BaseModel):
    celestial_object_id: str = Field(..., min_length=1)
    telescope_id: Optional[int] = None
    quest_id: Optional[str] = None
    observed_at: datetime
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    location_name: Optional[str] = None
    notes: Optional[str] = None


class ObservationUpdateRequest(BaseModel):
    notes: Optional[str] = None
    telescope_id: Optional[int] = None


class ObservationResponse(BaseModel):
    id: int
    user_id: int
    celestial_object_id: str
    telescope_id: Optional[int] = None
    quest_id: Optional[str] = None
    observed_at: datetime
    latitude: float
    longitude: float
    location_name: Optional[str] = None
    status: str
    notes: Optional[str] = None
    verification_score: Optional[float] = None
    verification_reason: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
