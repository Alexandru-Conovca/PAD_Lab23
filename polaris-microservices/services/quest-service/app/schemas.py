from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, Field


class QuestTaskResponse(BaseModel):
    id: int
    step_order: int
    title: str
    target_object_id: str
    target_object_name: str
    description: Optional[str] = None

    class Config:
        from_attributes = True


class QuestResponse(BaseModel):
    id: str
    title: str
    description: str
    difficulty: str
    tasks_count: int
    reward_xp: int
    created_at: datetime
    tasks: List[QuestTaskResponse] = []

    class Config:
        from_attributes = True


class QuestGenerateRequest(BaseModel):
    difficulty: str = Field("beginner", description="beginner, intermediate, advanced")
    target_object_type: Optional[str] = Field(None, description="planet, galaxy, nebula, star")


class TaskProgressItem(BaseModel):
    task_id: int
    title: str
    target_object_id: str
    target_object_name: str
    is_completed: bool
    completed_at: Optional[datetime] = None


class UserQuestProgressResponse(BaseModel):
    user_quest_id: int
    quest_id: str
    quest_title: str
    status: str
    progress_percent: float
    started_at: datetime
    completed_at: Optional[datetime] = None
    tasks: List[TaskProgressItem] = []
