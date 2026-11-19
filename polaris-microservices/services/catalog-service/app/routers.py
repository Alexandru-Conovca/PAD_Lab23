from typing import List, Optional
from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session

from .database import get_db
from .schemas import CategoryResponse, CelestialObjectResponse, FavoriteRequest, FavoriteResponse, PaginatedObjectsResponse
from .security import get_current_user_id
from .services import CatalogService

router = APIRouter(prefix="/api/catalog", tags=["Catalog"])


@router.get("/objects", response_model=PaginatedObjectsResponse)
def get_objects(
    type: Optional[str] = Query(None, description="Filter by celestial type (planet, galaxy, nebula, star)"),
    constellation: Optional[str] = Query(None, description="Filter by constellation"),
    visible_only: Optional[bool] = Query(None, description="Filter only currently visible objects"),
    search: Optional[str] = Query(None, description="Search query string"),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    db: Session = Depends(get_db),
):
    """Retrieve catalog objects with filtering and pagination."""
    return CatalogService.list_objects(
        db,
        type_=type,
        constellation=constellation,
        visible_only=visible_only,
        search=search,
        page=page,
        limit=limit,
    )


@router.get("/objects/search", response_model=List[CelestialObjectResponse])
def search_objects(
    q: str = Query(..., min_length=1, description="Search query"),
    db: Session = Depends(get_db),
):
    """Search celestial objects by name, constellation, or description."""
    return CatalogService.search(db, q)


@router.get("/objects/{id}", response_model=CelestialObjectResponse)
def get_object(id: str, db: Session = Depends(get_db)):
    """Retrieve details of a single celestial object by its unique ID."""
    return CatalogService.get_by_id(db, id)


@router.get("/categories", response_model=List[CategoryResponse])
def get_categories(db: Session = Depends(get_db)):
    """Retrieve the list of astronomical object categories."""
    return CatalogService.list_categories(db)


@router.get("/favorites", response_model=List[FavoriteResponse])
def get_favorites(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Retrieve all favorite celestial objects for the authenticated user."""
    return CatalogService.list_favorites(db, user_id)


@router.post("/favorites", response_model=FavoriteResponse, status_code=status.HTTP_201_CREATED)
def add_favorite(
    req: FavoriteRequest,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Add a celestial object to the user's favorites list."""
    return CatalogService.add_favorite(db, user_id, req)


@router.delete("/favorites/{id}", status_code=status.HTTP_204_NO_CONTENT)
def remove_favorite(
    id: str,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Remove a celestial object from the user's favorites list."""
    CatalogService.remove_favorite(db, user_id, id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
