from typing import List, Optional
from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from .database import get_db
from .schemas import QuestGenerateRequest, QuestResponse, UserQuestProgressResponse
from .security import get_current_user_id
from .services import QuestService

router = APIRouter(prefix="/api/quests", tags=["Quests"])


@router.get("", response_model=List[QuestResponse])
def get_quests(
    difficulty: Optional[str] = Query(None, description="Filter by difficulty (beginner, intermediate, advanced)"),
    db: Session = Depends(get_db),
):
    """Retrieve catalog of available observation quests."""
    return QuestService.list_quests(db, difficulty)


@router.post("/generate", response_model=QuestResponse, status_code=status.HTTP_201_CREATED)
def generate_quest(
    req: QuestGenerateRequest,
    db: Session = Depends(get_db),
):
    """Generate a procedural astronomical quest based on difficulty and sky targets."""
    return QuestService.generate_quest(db, req)


@router.get("/my", response_model=List[UserQuestProgressResponse])
def get_my_quests(
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Retrieve all started and completed quests for current user."""
    return QuestService.list_user_quests(db, user_id)


@router.post("/{id}/start", response_model=UserQuestProgressResponse)
def start_quest(
    id: str,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Enroll the current user in a quest and initiate task tracking."""
    return QuestService.start_quest(db, user_id, id)


@router.get("/{id}/progress", response_model=UserQuestProgressResponse)
def get_quest_progress(
    id: str,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Retrieve current completion progress and task checklist for a quest."""
    return QuestService.get_progress(db, user_id, id)


@router.post("/{id}/complete", response_model=UserQuestProgressResponse)
def complete_quest(
    id: str,
    user_id: int = Depends(get_current_user_id),
    db: Session = Depends(get_db),
):
    """Mark a quest as completed and award progress."""
    return QuestService.complete_quest(db, user_id, id)
