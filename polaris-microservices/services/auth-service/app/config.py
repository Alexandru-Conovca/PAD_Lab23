from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    service_name: str = "auth-service"
    host: str = "0.0.0.0"
    port: int = 8001
    database_url: str = "postgresql+psycopg2://postgres:postgres@postgres:5432/auth_db"
    jwt_secret: str = "super-secret-polaris-key-change-in-production-2026"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60
    refresh_token_expire_days: int = 7
    log_level: str = "INFO"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
