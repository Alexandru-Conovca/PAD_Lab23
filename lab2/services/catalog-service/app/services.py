from typing import List, Optional
from fastapi import HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload

from .models import CelestialObject, Favorite, ObjectCategory
from .schemas import FavoriteRequest, PaginatedObjectsResponse

SEED_CATEGORIES = [
    {"id": "planets", "name": "Planets", "description": "Major planets of our Solar System"},
    {"id": "galaxies", "name": "Galaxies", "description": "Distant collections of billions of stars"},
    {"id": "nebulae", "name": "Nebulae", "description": "Interstellar clouds of dust, hydrogen, and plasma"},
    {"id": "stars", "name": "Stars & Clusters", "description": "Individual stars, binary systems, and open clusters"},
]

SEED_OBJECTS = [
    {
        "id": "mars",
        "name": "Mars",
        "type": "planet",
        "category_id": "planets",
        "description": "The red planet and a rewarding target for a small telescope.",
        "magnitude": -1.8,
        "right_ascension": 190.5,
        "declination": -5.0,
        "coordinates_str": "RA 12h 42m / Dec -05°",
        "constellation": "Virgo",
        "is_visible_now": True,
    },
    {
        "id": "saturn",
        "name": "Saturn",
        "type": "planet",
        "category_id": "planets",
        "description": "A gas giant famous for its bright, delicate ring system.",
        "magnitude": 0.7,
        "right_ascension": 349.5,
        "declination": -7.0,
        "coordinates_str": "RA 23h 18m / Dec -07°",
        "constellation": "Aquarius",
        "is_visible_now": True,
    },
    {
        "id": "jupiter",
        "name": "Jupiter",
        "type": "planet",
        "category_id": "planets",
        "description": "The largest planet with vivid cloud belts and four Galilean moons.",
        "magnitude": -2.4,
        "right_ascension": 46.25,
        "declination": 16.5,
        "coordinates_str": "RA 03h 05m / Dec +16°",
        "constellation": "Aries",
        "is_visible_now": True,
    },
    {
        "id": "m31",
        "name": "Andromeda Galaxy (M31)",
        "type": "galaxy",
        "category_id": "galaxies",
        "description": "Our nearest major galactic neighbor, visible as a soft oval glow.",
        "magnitude": 3.4,
        "right_ascension": 10.5,
        "declination": 41.25,
        "coordinates_str": "RA 00h 42m / Dec +41°",
        "constellation": "Andromeda",
        "is_visible_now": True,
    },
    {
        "id": "m42",
        "name": "Orion Nebula (M42)",
        "type": "nebula",
        "category_id": "nebulae",
        "description": "A stellar nursery with bright, intricate clouds of gas.",
        "magnitude": 4.0,
        "right_ascension": 83.75,
        "declination": -5.4,
        "coordinates_str": "RA 05h 35m / Dec -05°",
        "constellation": "Orion",
        "is_visible_now": False,
    },
    {
        "id": "m45",
        "name": "Pleiades (M45)",
        "type": "star",
        "category_id": "stars",
        "description": "A compact and beautiful open cluster known as the Seven Sisters.",
        "magnitude": 1.6,
        "right_ascension": 56.75,
        "declination": 24.1,
        "coordinates_str": "RA 03h 47m / Dec +24°",
        "constellation": "Taurus",
        "is_visible_now": False,
    },
    {
        "id": "m57",
        "name": "Ring Nebula (M57)",
        "type": "nebula",
        "category_id": "nebulae",
        "description": "A compact planetary nebula with a distinctive smoke-ring shape.",
        "magnitude": 8.8,
        "right_ascension": 283.25,
        "declination": 33.0,
        "coordinates_str": "RA 18h 53m / Dec +33°",
        "constellation": "Lyra",
        "is_visible_now": True,
    },
    {
        "id": "vega",
        "name": "Vega",
        "type": "star",
        "category_id": "stars",
        "description": "A brilliant blue-white star and anchor of the Summer Triangle.",
        "magnitude": 0.0,
        "right_ascension": 279.25,
        "declination": 38.8,
        "coordinates_str": "RA 18h 37m / Dec +38°",
        "constellation": "Lyra",
        "is_visible_now": True,
    },
    {
        "id": "albireo",
        "name": "Albireo",
        "type": "star",
        "category_id": "stars",
        "description": "A striking double star with contrasting golden and blue components.",
        "magnitude": 2.9,
        "right_ascension": 292.75,
        "declination": 28.0,
        "coordinates_str": "RA 19h 31m / Dec +28°",
        "constellation": "Cygnus",
        "is_visible_now": True,
    },
]


class CatalogService:
    @staticmethod
    def seed_data_if_needed(db: Session):
        if db.query(ObjectCategory).count() == 0:
            for cat in SEED_CATEGORIES:
                db.add(ObjectCategory(**cat))
            db.commit()

        if db.query(CelestialObject).count() == 0:
            for obj in SEED_OBJECTS:
                db.add(CelestialObject(**obj))
            db.commit()

    @staticmethod
    def list_objects(
        db: Session,
        type_: Optional[str] = None,
        constellation: Optional[str] = None,
        visible_only: Optional[bool] = None,
        search: Optional[str] = None,
        page: int = 1,
        limit: int = 20,
    ) -> PaginatedObjectsResponse:
        query = db.query(CelestialObject)

        if type_:
            query = query.filter(CelestialObject.type == type_.lower())
        if constellation:
            query = query.filter(CelestialObject.constellation.ilike(f"%{constellation}%"))
        if visible_only is not None:
            query = query.filter(CelestialObject.is_visible_now == visible_only)
        if search:
            query = query.filter(
                or_(
                    CelestialObject.name.ilike(f"%{search}%"),
                    CelestialObject.description.ilike(f"%{search}%"),
                    CelestialObject.constellation.ilike(f"%{search}%"),
                )
            )

        total = query.count()
        offset = (page - 1) * limit
        items = query.order_by(CelestialObject.magnitude.asc()).offset(offset).limit(limit).all()

        return PaginatedObjectsResponse(
            items=items,
            page=page,
            limit=limit,
            total=total,
        )

    @staticmethod
    def get_by_id(db: Session, object_id: str) -> CelestialObject:
        obj = db.query(CelestialObject).filter(CelestialObject.id == object_id).first()
        if not obj:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Celestial object '{object_id}' not found",
            )
        return obj

    @staticmethod
    def search(db: Session, q: str) -> List[CelestialObject]:
        if not q or not q.strip():
            return []
        term = f"%{q.strip()}%"
        return db.query(CelestialObject).filter(
            or_(
                CelestialObject.name.ilike(term),
                CelestialObject.description.ilike(term),
                CelestialObject.constellation.ilike(term),
                CelestialObject.type.ilike(term),
            )
        ).all()

    @staticmethod
    def list_categories(db: Session) -> List[ObjectCategory]:
        return db.query(ObjectCategory).all()

    @staticmethod
    def list_favorites(db: Session, user_id: int) -> List[Favorite]:
        return (
            db.query(Favorite)
            .options(joinedload(Favorite.celestial_object))
            .filter(Favorite.user_id == user_id)
            .order_by(Favorite.created_at.desc())
            .all()
        )

    @staticmethod
    def add_favorite(db: Session, user_id: int, req: FavoriteRequest) -> Favorite:
        # Check object existence
        obj = db.query(CelestialObject).filter(CelestialObject.id == req.object_id).first()
        if not obj:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Celestial object '{req.object_id}' not found",
            )
        fav = db.query(Favorite).filter(Favorite.user_id == user_id, Favorite.object_id == req.object_id).first()
        if fav:
            return fav
        new_fav = Favorite(user_id=user_id, object_id=req.object_id)
        db.add(new_fav)
        db.commit()
        db.refresh(new_fav)
        return new_fav

    @staticmethod
    def remove_favorite(db: Session, user_id: int, object_id: str):
        fav = db.query(Favorite).filter(Favorite.user_id == user_id, Favorite.object_id == object_id).first()
        if not fav:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Favorite entry not found",
            )
        db.delete(fav)
        db.commit()
