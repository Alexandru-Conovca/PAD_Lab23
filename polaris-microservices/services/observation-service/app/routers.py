from typing import List, Optional
from fastapi import APIRouter, Depends, Query, Response, status
from sqlalchemy.orm import Session

from .database import get_db
from .schemas import ObservationCreateRequest, ObservationResponse, ObservationUpdateRequest
from .security import get_current_user_id
from .services import ObservationService

router = APIRouter(prefix="/api/observations", tags=["Observations"])


@router.post("", response_model=ObservationResponse, status_code=status.HTTP_202_ACCEPTED)
def create_observation(
    req: ObservationCreateRequest,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Submit a newly completed astronomical observation for asynchronous verification."""
    return ObservationService.create(db, user_id, req)


@router.get("", response_model=List[ObservationResponse])
def get_observations(
    status: Optional[str] = Query(None, description="Filter by status (PENDING, VERIFIED, REJECTED)"),
    quest_id: Optional[str] = Query(None, description="Filter by associated quest ID"),
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Retrieve history of celestial observations for the current user."""
    return ObservationService.list_observations(db, user_id, status_filter=status, quest_id=quest_id)


@router.get("/{id}", response_model=ObservationResponse)
def get_observation(
    id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Retrieve details and verification status of a specific observation."""
    return ObservationService.get_by_id(db, user_id, id)


@router.put("/{id}", response_model=ObservationResponse)
def update_observation(
    id: int,
    req: ObservationUpdateRequest,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Update notes or telescope equipment reference for an observation."""
    return ObservationService.update(db, user_id, id, req)


@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_observation(
    id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Delete an observation record."""
    ObservationService.delete(db, user_id, id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
