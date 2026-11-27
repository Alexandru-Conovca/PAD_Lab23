from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    service_name: str = "quest-service"
    host: str = "0.0.0.0"
    port: int = 8005
    database_url: str = "postgresql+psycopg://postgres:postgres@postgres:5432/quest_db"
    rabbitmq_host: str = "rabbitmq"
    rabbitmq_port: int = 5672
    rabbitmq_user: str = "guest"
    rabbitmq_password: str = "guest"
    catalog_service_url: str = "http://catalog-service:8002"
    jwt_secret: str = "super-secret-polaris-key-change-in-production-2026"
    jwt_algorithm: str = "HS256"
    log_level: str = "INFO"

    @property
    def rabbitmq_url(self) -> str:
        return f"amqp://{self.rabbitmq_user}:{self.rabbitmq_password}@{self.rabbitmq_host}:{self.rabbitmq_port}/"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
