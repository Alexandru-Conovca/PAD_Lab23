from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class TelescopeCreateRequest(BaseModel):
    name: str = Field(..., min_length=2, max_length=150)
    aperture: int = Field(..., gt=0, description="Aperture diameter in mm")
    focal_length: int = Field(..., gt=0, description="Focal length in mm")
    mount_type: str = Field(..., min_length=2, max_length=100)
    is_active: bool = False
    notes: Optional[str] = None


class TelescopeUpdateRequest(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=150)
    aperture: Optional[int] = Field(None, gt=0)
    focal_length: Optional[int] = Field(None, gt=0)
    mount_type: Optional[str] = Field(None, min_length=2, max_length=100)
    is_active: Optional[bool] = None
    notes: Optional[str] = None


class TelescopeResponse(BaseModel):
    id: int
    user_id: int
    name: str
    aperture: int
    focal_length: int
    mount_type: str
    is_active: bool
    notes: Optional[str] = None
    focal_ratio: float
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
