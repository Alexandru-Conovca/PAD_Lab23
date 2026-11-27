import uuid
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from .logging_config import setup_logger
from .models import Quest, QuestProgress, QuestTask, UserQuest
from .schemas import (
    QuestGenerateRequest,
    QuestResponse,
    TaskProgressItem,
    UserQuestProgressResponse,
)

logger = setup_logger("quest-service")

SEED_QUESTS = [
    {
        "id": "solar",
        "title": "Tour of the Solar System",
        "description": "Visit bright planets and learn to read their changing positions in the sky.",
        "difficulty": "beginner",
        "tasks_count": 3,
        "reward_xp": 150,
        "tasks": [
            {"step_order": 1, "title": "Observe Mars", "target_object_id": "mars", "target_object_name": "Mars"},
            {"step_order": 2, "title": "Observe Saturn", "target_object_id": "saturn", "target_object_name": "Saturn"},
            {"step_order": 3, "title": "Observe Jupiter", "target_object_id": "jupiter", "target_object_name": "Jupiter"},
        ],
    },
    {
        "id": "deep-sky",
        "title": "Deep Sky Wonders of Autumn",
        "description": "Build confidence finding galaxies and nebulae beyond our solar neighborhood.",
        "difficulty": "intermediate",
        "tasks_count": 3,
        "reward_xp": 300,
        "tasks": [
            {"step_order": 1, "title": "Center M31", "target_object_id": "m31", "target_object_name": "Andromeda Galaxy (M31)"},
            {"step_order": 2, "title": "Explore Orion Nebula", "target_object_id": "m42", "target_object_name": "Orion Nebula (M42)"},
            {"step_order": 3, "title": "Resolve Ring Nebula", "target_object_id": "m57", "target_object_name": "Ring Nebula (M57)"},
        ],
    },
    {
        "id": "binary",
        "title": "Binary Star Hunt",
        "description": "Resolve colorful double stars and compare their apparent brightness.",
        "difficulty": "intermediate",
        "tasks_count": 3,
        "reward_xp": 250,
        "tasks": [
            {"step_order": 1, "title": "Find Vega", "target_object_id": "vega", "target_object_name": "Vega"},
            {"step_order": 2, "title": "Split Albireo", "target_object_id": "albireo", "target_object_name": "Albireo"},
            {"step_order": 3, "title": "Observe Pleiades Cluster", "target_object_id": "m45", "target_object_name": "Pleiades (M45)"},
        ],
    },
]


class QuestService:
    @staticmethod
    def seed_data_if_needed(db: Session):
        if db.query(Quest).count() == 0:
            for q_data in SEED_QUESTS:
                tasks_data = q_data["tasks"]
                quest = Quest(
                    id=q_data["id"],
                    title=q_data["title"],
                    description=q_data["description"],
                    difficulty=q_data["difficulty"],
                    tasks_count=q_data["tasks_count"],
                    reward_xp=q_data["reward_xp"],
                )
                db.add(quest)
                db.flush()
                for t in tasks_data:
                    task = QuestTask(
                        quest_id=quest.id,
                        step_order=t["step_order"],
                        title=t["title"],
                        target_object_id=t["target_object_id"],
                        target_object_name=t["target_object_name"],
                    )
                    db.add(task)
            db.commit()

    @staticmethod
    def list_quests(db: Session, difficulty: Optional[str] = None) -> List[Quest]:
        q = db.query(Quest)
        if difficulty:
            q = q.filter(Quest.difficulty == difficulty.lower())
        return q.all()

    @staticmethod
    def get_quest(db: Session, quest_id: str) -> Quest:
        q = db.query(Quest).filter(Quest.id == quest_id).first()
        if not q:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Quest '{quest_id}' not found",
            )
        return q

    @staticmethod
    def generate_quest(db: Session, req: QuestGenerateRequest) -> Quest:
        """Rule-based quest generator."""
        qid = f"generated-{uuid.uuid4().hex[:8]}"
        difficulty = req.difficulty.lower()

        if difficulty == "advanced":
            title = "Master Stargazer: Messier Marathon"
            desc = "Push your optical equipment to the limit by observing faint nebulae and distant clusters."
            reward_xp = 500
            tasks_list = [
                {"step_order": 1, "title": "Capture M31 Andromeda", "target_object_id": "m31", "target_object_name": "Andromeda Galaxy (M31)"},
                {"step_order": 2, "title": "Observe M57 Ring Nebula", "target_object_id": "m57", "target_object_name": "Ring Nebula (M57)"},
            ]
        elif difficulty == "intermediate":
            title = "Cosmic Cartography Expedition"
            desc = "Navigate between distinct constellations and track celestial beacons."
            reward_xp = 300
            tasks_list = [
                {"step_order": 1, "title": "Find Vega in Lyra", "target_object_id": "vega", "target_object_name": "Vega"},
                {"step_order": 2, "title": "Track Saturn in Aquarius", "target_object_id": "saturn", "target_object_name": "Saturn"},
            ]
        else:
            title = "First Light: Planetary Rendezvous"
            desc = "A welcoming mission to orient yourself with the brightest night sky targets."
            reward_xp = 150
            tasks_list = [
                {"step_order": 1, "title": "Find and view Mars", "target_object_id": "mars", "target_object_name": "Mars"},
                {"step_order": 2, "title": "Observe the brilliant star Vega", "target_object_id": "vega", "target_object_name": "Vega"},
            ]

        new_quest = Quest(
            id=qid,
            title=title,
            description=desc,
            difficulty=difficulty,
            tasks_count=len(tasks_list),
            reward_xp=reward_xp,
        )
        db.add(new_quest)
        db.flush()

        for t in tasks_list:
            task = QuestTask(
                quest_id=new_quest.id,
                step_order=t["step_order"],
                title=t["title"],
                target_object_id=t["target_object_id"],
                target_object_name=t["target_object_name"],
            )
            db.add(task)
        db.commit()
        db.refresh(new_quest)
        return new_quest

    @staticmethod
    def start_quest(db: Session, user_id: int, quest_id: str) -> UserQuestProgressResponse:
        quest = QuestService.get_quest(db, quest_id)

        # Check if already started
        user_quest = db.query(UserQuest).filter(
            UserQuest.user_id == user_id,
            UserQuest.quest_id == quest_id,
        ).first()

        if not user_quest:
            user_quest = UserQuest(
                user_id=user_id,
                quest_id=quest_id,
                status="in_progress",
                progress_percent=0.0,
            )
            db.add(user_quest)
            db.flush()

            for task in quest.tasks:
                prog = QuestProgress(
                    user_quest_id=user_quest.id,
                    task_id=task.id,
                    is_completed=False,
                )
                db.add(prog)
            db.commit()
            db.refresh(user_quest)

        return QuestService.get_progress(db, user_id, quest_id)

    @staticmethod
    def get_progress(db: Session, user_id: int, quest_id: str) -> UserQuestProgressResponse:
        user_quest = db.query(UserQuest).filter(
            UserQuest.user_id == user_id,
            UserQuest.quest_id == quest_id,
        ).first()

        if not user_quest:
            quest = QuestService.get_quest(db, quest_id)
            return UserQuestProgressResponse(
                user_quest_id=0,
                quest_id=quest.id,
                quest_title=quest.title,
                status="not_started",
                progress_percent=0.0,
                started_at=datetime.now(timezone.utc),
                tasks=[
                    TaskProgressItem(
                        task_id=t.id,
                        title=t.title,
                        target_object_id=t.target_object_id,
                        target_object_name=t.target_object_name,
                        is_completed=False,
                    )
                    for t in quest.tasks
                ],
            )

        task_items = []
        for t_prog in user_quest.task_progresses:
            task = t_prog.task
            task_items.append(
                TaskProgressItem(
                    task_id=task.id,
                    title=task.title,
                    target_object_id=task.target_object_id,
                    target_object_name=task.target_object_name,
                    is_completed=t_prog.is_completed,
                    completed_at=t_prog.completed_at,
                )
            )

        return UserQuestProgressResponse(
            user_quest_id=user_quest.id,
            quest_id=user_quest.quest_id,
            quest_title=user_quest.quest.title,
            status=user_quest.status,
            progress_percent=user_quest.progress_percent,
            started_at=user_quest.started_at,
            completed_at=user_quest.completed_at,
            tasks=task_items,
        )

    @staticmethod
    def complete_quest(db: Session, user_id: int, quest_id: str) -> UserQuestProgressResponse:
        user_quest = db.query(UserQuest).filter(
            UserQuest.user_id == user_id,
            UserQuest.quest_id == quest_id,
        ).first()

        if not user_quest:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Quest has not been started.")

        now = datetime.now(timezone.utc)
        for t_prog in user_quest.task_progresses:
            t_prog.is_completed = True
            t_prog.completed_at = now

        user_quest.status = "completed"
        user_quest.progress_percent = 100.0
        user_quest.completed_at = now
        db.commit()

        return QuestService.get_progress(db, user_id, quest_id)

    @staticmethod
    def list_user_quests(db: Session, user_id: int) -> List[UserQuestProgressResponse]:
        user_quests = db.query(UserQuest).filter(UserQuest.user_id == user_id).all()
        return [QuestService.get_progress(db, user_id, uq.quest_id) for uq in user_quests]

    @staticmethod
    def handle_observation_verified(db: Session, data: dict):
        user_id = int(data["user_id"])
        target_object_id = str(data["celestial_object_id"]).lower()
        specific_quest_id = data.get("quest_id")

        query = db.query(UserQuest).filter(
            UserQuest.user_id == user_id,
            UserQuest.status == "in_progress",
        )
        if specific_quest_id:
            query = query.filter(UserQuest.quest_id == specific_quest_id)

        active_user_quests = query.all()
        for uq in active_user_quests:
            updated = False
            for t_prog in uq.task_progresses:
                if t_prog.task.target_object_id.lower() == target_object_id and not t_prog.is_completed:
                    t_prog.is_completed = True
                    t_prog.completed_at = datetime.now(timezone.utc)
                    updated = True
                    logger.info(f"Completed task '{t_prog.task.title}' for user {user_id} in quest '{uq.quest_id}'")

            if updated:
                total_tasks = len(uq.task_progresses)
                completed_count = sum(1 for p in uq.task_progresses if p.is_completed)
                uq.progress_percent = round((completed_count / total_tasks) * 100.0, 1)

                if completed_count == total_tasks:
                    uq.status = "completed"
                    uq.completed_at = datetime.now(timezone.utc)
                    logger.info(f"User {user_id} fully COMPLETED quest '{uq.quest_id}'!")
                db.commit()
