from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    service_name: str = "weather-service"
    host: str = "0.0.0.0"
    port: int = 8007
    database_url: str = "postgresql+psycopg://postgres:postgres@postgres:5432/weather_db"
    open_meteo_api_url: str = "https://api.open-meteo.com/v1/forecast"
    log_level: str = "INFO"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
