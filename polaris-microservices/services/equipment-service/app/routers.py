from typing import List
from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from .database import get_db
from .schemas import TelescopeCreateRequest, TelescopeResponse, TelescopeUpdateRequest
from .security import get_current_user_id
from .services import EquipmentService

router = APIRouter(prefix="/api/equipment", tags=["Equipment"])


@router.get("", response_model=List[TelescopeResponse])
def get_equipment_list(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Retrieve all telescopes owned by the authenticated user."""
    return EquipmentService.list_equipment(db, user_id)


@router.post("", response_model=TelescopeResponse, status_code=status.HTTP_201_CREATED)
def create_telescope(
    req: TelescopeCreateRequest,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Add a new telescope or observing equipment."""
    return EquipmentService.create(db, user_id, req)


@router.get("/{id}", response_model=TelescopeResponse)
def get_telescope(
    id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Retrieve details of a telescope by its ID."""
    return EquipmentService.get_by_id(db, user_id, id)


@router.put("/{id}", response_model=TelescopeResponse)
def update_telescope(
    id: int,
    req: TelescopeUpdateRequest,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Update characteristics of an existing telescope."""
    return EquipmentService.update(db, user_id, id, req)


@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_telescope(
    id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Remove a telescope from user's equipment."""
    EquipmentService.delete(db, user_id, id)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/{id}/set-active", response_model=TelescopeResponse)
def set_active_telescope(
    id: int,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Designate this telescope as the active equipment for observations."""
    return EquipmentService.set_active(db, user_id, id)
