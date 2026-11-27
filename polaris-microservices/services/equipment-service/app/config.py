from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    service_name: str = "equipment-service"
    host: str = "0.0.0.0"
    port: int = 8003
    database_url: str = "postgresql+psycopg://postgres:postgres@postgres:5432/equipment_db"
    jwt_secret: str = "super-secret-polaris-key-change-in-production-2026"
    jwt_algorithm: str = "HS256"
    log_level: str = "INFO"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
