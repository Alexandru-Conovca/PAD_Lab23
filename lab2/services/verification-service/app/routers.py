from typing import List
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session

from .database import get_db
from .schemas import VerificationResultResponse, VerificationRuleResponse, VerifyObservationInput
from .services import VerificationService

router = APIRouter(prefix="/api/verification", tags=["Verification"])


@router.post("/verify", response_model=VerificationResultResponse, status_code=status.HTTP_200_OK)
def trigger_verify(req: VerifyObservationInput, db: Session = Depends(get_db)):
    """Trigger synchronous on-demand verification for an observation."""
    return VerificationService.verify_observation(db, req.model_dump())


@router.get("/rules", response_model=List[VerificationRuleResponse])
def get_rules(db: Session = Depends(get_db)):
    """Retrieve active automated verification rules and constraints."""
    return VerificationService.get_rules(db)


@router.get("/{id}", response_model=VerificationResultResponse)
def get_result(id: int, db: Session = Depends(get_db)):
    """Retrieve observation verification result by result ID or observation ID."""
    return VerificationService.get_result_by_id(db, id)
