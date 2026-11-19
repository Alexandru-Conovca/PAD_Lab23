from datetime import datetime, timezone
from sqlalchemy import Boolean, Column, DateTime, Float, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from .database import Base


def utcnow():
    return datetime.now(timezone.utc)


class Quest(Base):
    __tablename__ = "quests"

    id = Column(String(50), primary_key=True)
    title = Column(String(150), nullable=False)
    description = Column(Text, nullable=False)
    difficulty = Column(String(50), default="beginner", nullable=False)  # beginner, intermediate, advanced
    tasks_count = Column(Integer, default=1, nullable=False)
    reward_xp = Column(Integer, default=100, nullable=False)
    created_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)

    tasks = relationship("QuestTask", back_populates="quest", cascade="all, delete-orphan", order_by="QuestTask.step_order")
    user_quests = relationship("UserQuest", back_populates="quest", cascade="all, delete-orphan")


class QuestTask(Base):
    __tablename__ = "quest_tasks"

    id = Column(Integer, primary_key=True, index=True)
    quest_id = Column(String(50), ForeignKey("quests.id", ondelete="CASCADE"), nullable=False, index=True)
    step_order = Column(Integer, default=1, nullable=False)
    title = Column(String(150), nullable=False)
    target_object_id = Column(String(50), nullable=False)
    target_object_name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)

    quest = relationship("Quest", back_populates="tasks")
    progress_records = relationship("QuestProgress", back_populates="task", cascade="all, delete-orphan")


class UserQuest(Base):
    __tablename__ = "user_quests"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    quest_id = Column(String(50), ForeignKey("quests.id", ondelete="CASCADE"), nullable=False, index=True)
    status = Column(String(50), default="in_progress", nullable=False)  # in_progress, completed, abandoned
    progress_percent = Column(Float, default=0.0, nullable=False)
    started_at = Column(DateTime(timezone=True), default=utcnow, nullable=False)
    completed_at = Column(DateTime(timezone=True), nullable=True)

    quest = relationship("Quest", back_populates="user_quests")
    task_progresses = relationship("QuestProgress", back_populates="user_quest", cascade="all, delete-orphan")


class QuestProgress(Base):
    __tablename__ = "quest_progress"

    id = Column(Integer, primary_key=True, index=True)
    user_quest_id = Column(Integer, ForeignKey("user_quests.id", ondelete="CASCADE"), nullable=False, index=True)
    task_id = Column(Integer, ForeignKey("quest_tasks.id", ondelete="CASCADE"), nullable=False, index=True)
    is_completed = Column(Boolean, default=False, nullable=False)
    completed_at = Column(DateTime(timezone=True), nullable=True)

    user_quest = relationship("UserQuest", back_populates="task_progresses")
    task = relationship("QuestTask", back_populates="progress_records")
