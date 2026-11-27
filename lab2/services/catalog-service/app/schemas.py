from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel


class CategoryResponse(BaseModel):
    id: str
    name: str
    description: Optional[str] = None

    class Config:
        from_attributes = True


class CelestialObjectResponse(BaseModel):
    id: str
    name: str
    type: str
    category_id: Optional[str] = None
    description: str
    magnitude: float
    right_ascension: float
    declination: float
    coordinates_str: str
    constellation: str
    is_visible_now: bool
    created_at: datetime

    class Config:
        from_attributes = True


class PaginatedObjectsResponse(BaseModel):
    items: List[CelestialObjectResponse]
    page: int
    limit: int
    total: int


class FavoriteRequest(BaseModel):
    object_id: str


class FavoriteResponse(BaseModel):
    id: int
    user_id: int
    object_id: str
    created_at: datetime
    celestial_object: Optional[CelestialObjectResponse] = None

    class Config:
        from_attributes = True
