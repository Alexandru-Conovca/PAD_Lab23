from typing import List
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from .models import Telescope
from .schemas import TelescopeCreateRequest, TelescopeUpdateRequest


class EquipmentService:
    @staticmethod
    def list_equipment(db: Session, user_id: int) -> List[Telescope]:
        return db.query(Telescope).filter(Telescope.user_id == user_id).order_by(Telescope.id.desc()).all()

    @staticmethod
    def get_by_id(db: Session, user_id: int, telescope_id: int) -> Telescope:
        t = db.query(Telescope).filter(Telescope.id == telescope_id, Telescope.user_id == user_id).first()
        if not t:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Telescope {telescope_id} not found",
            )
        return t

    @staticmethod
    def create(db: Session, user_id: int, req: TelescopeCreateRequest) -> Telescope:
        if req.is_active:
            db.query(Telescope).filter(Telescope.user_id == user_id).update({"is_active": False})

        t = Telescope(
            user_id=user_id,
            name=req.name,
            aperture=req.aperture,
            focal_length=req.focal_length,
            mount_type=req.mount_type,
            is_active=req.is_active,
            notes=req.notes,
        )
        db.add(t)
        db.commit()
        db.refresh(t)
        return t

    @staticmethod
    def update(db: Session, user_id: int, telescope_id: int, req: TelescopeUpdateRequest) -> Telescope:
        t = EquipmentService.get_by_id(db, user_id, telescope_id)

        if req.is_active is True:
            db.query(Telescope).filter(Telescope.user_id == user_id, Telescope.id != telescope_id).update({"is_active": False})

        for key, val in req.model_dump(exclude_unset=True).items():
            setattr(t, key, val)

        db.commit()
        db.refresh(t)
        return t

    @staticmethod
    def delete(db: Session, user_id: int, telescope_id: int):
        t = EquipmentService.get_by_id(db, user_id, telescope_id)
        db.delete(t)
        db.commit()

    @staticmethod
    def set_active(db: Session, user_id: int, telescope_id: int) -> Telescope:
        t = EquipmentService.get_by_id(db, user_id, telescope_id)
        db.query(Telescope).filter(Telescope.user_id == user_id).update({"is_active": False})
        t.is_active = True
        db.commit()
        db.refresh(t)
        return t
