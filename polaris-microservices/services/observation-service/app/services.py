from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from .logging_config import setup_logger
from .messaging import mq_client
from .models import Observation
from .schemas import ObservationCreateRequest, ObservationUpdateRequest

logger = setup_logger("observation-service")


class ObservationService:
    @staticmethod
    def create(db: Session, user_id: int, req: ObservationCreateRequest) -> Observation:
        obs = Observation(
            user_id=user_id,
            celestial_object_id=req.celestial_object_id,
            telescope_id=req.telescope_id,
            quest_id=req.quest_id,
            observed_at=req.observed_at,
            latitude=req.latitude,
            longitude=req.longitude,
            location_name=req.location_name,
            status="PENDING",
            notes=req.notes,
        )
        db.add(obs)
        db.commit()
        db.refresh(obs)

        # Publish event to RabbitMQ
        event_payload = {
            "observation_id": obs.id,
            "user_id": obs.user_id,
            "celestial_object_id": obs.celestial_object_id,
            "quest_id": obs.quest_id,
            "latitude": obs.latitude,
            "longitude": obs.longitude,
            "observed_at": obs.observed_at.isoformat(),
        }
        mq_client.publish_observation_submitted(event_payload)

        return obs

    @staticmethod
    def list_observations(
        db: Session,
        user_id: int,
        status_filter: Optional[str] = None,
        quest_id: Optional[str] = None,
    ) -> List[Observation]:
        q = db.query(Observation).filter(Observation.user_id == user_id)
        if status_filter:
            q = q.filter(Observation.status == status_filter.upper())
        if quest_id:
            q = q.filter(Observation.quest_id == quest_id)
        return q.order_by(Observation.observed_at.desc()).all()

    @staticmethod
    def get_by_id(db: Session, user_id: int, obs_id: int) -> Observation:
        obs = db.query(Observation).filter(Observation.id == obs_id, Observation.user_id == user_id).first()
        if not obs:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Observation {obs_id} not found",
            )
        return obs

    @staticmethod
    def update(db: Session, user_id: int, obs_id: int, req: ObservationUpdateRequest) -> Observation:
        obs = ObservationService.get_by_id(db, user_id, obs_id)
        if req.notes is not None:
            obs.notes = req.notes
        if req.telescope_id is not None:
            obs.telescope_id = req.telescope_id
        db.commit()
        db.refresh(obs)
        return obs

    @staticmethod
    def delete(db: Session, user_id: int, obs_id: int):
        obs = ObservationService.get_by_id(db, user_id, obs_id)
        db.delete(obs)
        db.commit()

    @staticmethod
    def handle_verification_result(db: Session, data: dict):
        obs_id = int(data["observation_id"])
        new_status = data.get("status", "VERIFIED")
        score = data.get("score")
        reasons = data.get("reasons")

        obs = db.query(Observation).filter(Observation.id == obs_id).first()
        if not obs:
            logger.warning(f"Received verification result for unknown observation {obs_id}")
            return

        obs.status = new_status
        obs.verification_score = score
        obs.verification_reason = reasons
        db.commit()
        logger.info(f"Updated observation {obs_id} status to '{new_status}' (score={score})")
