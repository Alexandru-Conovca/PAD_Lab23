import json
from datetime import datetime, timezone
from typing import Dict, List, Optional
from fastapi import HTTPException, status
import httpx
from sqlalchemy.orm import Session

from .astronomy import calculate_altitude
from .config import settings
from .logging_config import setup_logger
from .messaging import mq_client
from .models import VerificationRequest, VerificationResult, VerificationRule
from .schemas import VerificationResultResponse, VerifyObservationInput

logger = setup_logger(settings.service_name, settings.log_level)

FALLBACK_OBJECT_COORDINATES = {
    "mars": {"ra": 190.5, "dec": -5.0, "name": "Mars"},
    "saturn": {"ra": 349.5, "dec": -7.0, "name": "Saturn"},
    "jupiter": {"ra": 46.25, "dec": 16.5, "name": "Jupiter"},
    "m31": {"ra": 10.5, "dec": 41.25, "name": "Andromeda Galaxy (M31)"},
    "m42": {"ra": 83.75, "dec": -5.4, "name": "Orion Nebula (M42)"},
    "m45": {"ra": 56.75, "dec": 24.1, "name": "Pleiades (M45)"},
    "m57": {"ra": 283.25, "dec": 33.0, "name": "Ring Nebula (M57)"},
    "vega": {"ra": 279.25, "dec": 38.8, "name": "Vega"},
    "albireo": {"ra": 292.75, "dec": 28.0, "name": "Albireo"},
}

DEFAULT_RULES = [
    {
        "rule_name": "horizon_altitude_check",
        "description": "Celestial object must have altitude above local horizon (degrees).",
        "threshold_value": 0.0,
    },
    {
        "rule_name": "max_cloud_cover_percent",
        "description": "Cloud cover percentage must not exceed threshold.",
        "threshold_value": 80.0,
    },
    {
        "rule_name": "coordinates_validity",
        "description": "Observer latitude between -90 and 90, longitude between -180 and 180.",
        "threshold_value": 1.0,
    },
]


class VerificationService:
    @staticmethod
    def seed_rules_if_needed(db: Session):
        if db.query(VerificationRule).count() == 0:
            for rule in DEFAULT_RULES:
                db.add(VerificationRule(**rule))
            db.commit()

    @staticmethod
    def get_rules(db: Session) -> List[VerificationRule]:
        return db.query(VerificationRule).filter(VerificationRule.is_active == True).all()

    @staticmethod
    def get_result_by_id(db: Session, res_id: int) -> VerificationResultResponse:
        result = db.query(VerificationResult).filter(
            (VerificationResult.id == res_id) | (VerificationResult.observation_id == res_id)
        ).first()
        if not result:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Verification result for id/observation_id {res_id} not found",
            )
        details = json.loads(result.details_json) if result.details_json else None
        return VerificationResultResponse(
            id=result.id,
            observation_id=result.observation_id,
            is_valid=result.is_valid,
            status=result.status,
            score=result.score,
            reasons=result.reasons,
            details=details,
            verified_at=result.verified_at,
        )

    @staticmethod
    def verify_observation(db: Session, data: dict) -> VerificationResultResponse:
        obs_id = int(data["observation_id"])
        user_id = int(data.get("user_id", 1))
        object_id = str(data["celestial_object_id"]).lower()
        lat = float(data["latitude"])
        lon = float(data["longitude"])
        raw_time = data["observed_at"]
        quest_id = data.get("quest_id")

        if isinstance(raw_time, str):
            obs_time = datetime.fromisoformat(raw_time.replace("Z", "+00:00"))
        else:
            obs_time = raw_time

        # Create verification request record
        req_record = VerificationRequest(
            observation_id=obs_id,
            user_id=user_id,
            celestial_object_id=object_id,
            latitude=lat,
            longitude=lon,
            observed_at=obs_time,
            status="PROCESSING",
        )
        db.add(req_record)
        db.commit()
        db.refresh(req_record)

        failure_reasons = []
        breakdown = {}

        # 1. Coordinates check
        if not (-90.0 <= lat <= 90.0 and -180.0 <= lon <= 180.0):
            failure_reasons.append(f"Invalid observer coordinates: ({lat}, {lon}).")

        # 2. Celestial object coordinates lookup
        ra_deg, dec_deg, obj_name = None, None, object_id
        try:
            with httpx.Client(timeout=3.0) as client:
                res = client.get(f"{settings.catalog_service_url}/api/catalog/objects/{object_id}")
                if res.status_code == 200:
                    cat_obj = res.json()
                    ra_deg = cat_obj.get("right_ascension")
                    dec_deg = cat_obj.get("declination")
                    obj_name = cat_obj.get("name", object_id)
        except Exception as e:
            logger.warning(f"Catalog service sync call failed: {e}. Checking local lookup table.")

        if ra_deg is None or dec_deg is None:
            if object_id in FALLBACK_OBJECT_COORDINATES:
                coord = FALLBACK_OBJECT_COORDINATES[object_id]
                ra_deg, dec_deg, obj_name = coord["ra"], coord["dec"], coord["name"]
            else:
                ra_deg, dec_deg = 180.0, 20.0

        # 3. Astronomical altitude above horizon check
        alt_deg = calculate_altitude(lat, lon, ra_deg, dec_deg, obs_time)
        breakdown["altitude_degrees"] = round(alt_deg, 2)
        breakdown["object_name"] = obj_name

        if alt_deg < 0.0:
            failure_reasons.append(
                f"{obj_name} was below the horizon ({alt_deg:.1f}°) at {obs_time.strftime('%H:%M UTC')}."
            )

        # 4. Weather conditions check
        cloud_cover = 20.0
        try:
            with httpx.Client(timeout=3.0) as client:
                res = client.get(
                    f"{settings.weather_service_url}/api/weather/conditions?latitude={lat}&longitude={lon}"
                )
                if res.status_code == 200:
                    weather_data = res.json()
                    cloud_cover = weather_data.get("cloud_cover", 20.0)
                    if not weather_data.get("is_suitable", True) and cloud_cover > 80.0:
                        failure_reasons.append(f"Excessive cloud cover ({cloud_cover:.0f}%) prevented observation.")
        except Exception as e:
            logger.warning(f"Weather service sync call failed: {e}. Proceeding with standard threshold.")

        breakdown["cloud_cover"] = cloud_cover

        # 5. Outcome determination
        if not failure_reasons:
            is_valid = True
            verification_status = "VERIFIED"
            score = round(min(1.0, 0.75 + (max(0.0, alt_deg) / 90.0) * 0.25), 2)
            reasons = f"Observation verified: {obj_name} was positioned {alt_deg:.1f}° above the horizon with {cloud_cover:.0f}% cloud cover."
        else:
            is_valid = False
            verification_status = "REJECTED"
            score = 0.2
            reasons = "Observation rejected: " + " ".join(failure_reasons)

        # Save result
        req_record.status = verification_status
        result_record = VerificationResult(
            request_id=req_record.id,
            observation_id=obs_id,
            is_valid=is_valid,
            status=verification_status,
            score=score,
            details_json=json.dumps(breakdown),
            reasons=reasons,
        )
        db.add(result_record)
        db.commit()
        db.refresh(result_record)

        # Publish event to RabbitMQ
        event_routing_key = "observation.verified" if is_valid else "observation.rejected"
        event_payload = {
            "observation_id": obs_id,
            "user_id": user_id,
            "quest_id": quest_id,
            "celestial_object_id": object_id,
            "status": verification_status,
            "score": score,
            "reasons": reasons,
            "verified_at": result_record.verified_at.isoformat(),
        }
        mq_client.publish_event(event_routing_key, event_payload)

        return VerificationResultResponse(
            id=result_record.id,
            observation_id=obs_id,
            is_valid=is_valid,
            status=verification_status,
            score=score,
            reasons=reasons,
            details=breakdown,
            verified_at=result_record.verified_at,
        )
