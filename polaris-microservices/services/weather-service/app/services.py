from datetime import datetime, timezone
from typing import Optional
import httpx
from sqlalchemy.orm import Session

from .config import settings
from .logging_config import setup_logger
from .models import ObservationConditions, WeatherForecast
from .schemas import HourlyForecastItem, ObservationConditionsResponse, WeatherCurrentResponse, WeatherForecastResponse

logger = setup_logger(settings.service_name, settings.log_level)


class WeatherService:
    @staticmethod
    async def get_current_weather(
        latitude: float,
        longitude: float,
        db: Session,
    ) -> WeatherCurrentResponse:
        url = (
            f"{settings.open_meteo_api_url}?"
            f"latitude={latitude}&longitude={longitude}&"
            "current=temperature_2m,relative_humidity_2m,cloud_cover,visibility,wind_speed_10m"
        )
        try:
            async with httpx.AsyncClient(timeout=3.5) as client:
                res = await client.get(url)
                if res.status_code == 200:
                    data = res.json()
                    curr = data.get("current", {})
                    temp = curr.get("temperature_2m", 15.0)
                    cloud = curr.get("cloud_cover", 20.0)
                    humidity = curr.get("relative_humidity_2m", 55.0)
                    vis = curr.get("visibility", 10000.0)
                    wind = curr.get("wind_speed_10m", 8.0)

                    record = WeatherForecast(
                        latitude=latitude,
                        longitude=longitude,
                        temperature=temp,
                        cloud_cover=cloud,
                        relative_humidity=humidity,
                        visibility=vis,
                        wind_speed=wind,
                        source="open-meteo",
                    )
                    db.add(record)
                    db.commit()

                    return WeatherCurrentResponse(
                        latitude=latitude,
                        longitude=longitude,
                        timestamp=datetime.now(timezone.utc),
                        temperature=temp,
                        cloud_cover=cloud,
                        relative_humidity=humidity,
                        visibility=vis,
                        wind_speed=wind,
                        source="open-meteo",
                    )
        except Exception as e:
            logger.warning(f"Failed to fetch live weather from Open-Meteo: {e}. Using fallback model.")

        # Check latest cached record
        cached = (
            db.query(WeatherForecast)
            .filter(
                WeatherForecast.latitude.between(latitude - 0.5, latitude + 0.5),
                WeatherForecast.longitude.between(longitude - 0.5, longitude + 0.5),
            )
            .order_by(WeatherForecast.id.desc())
            .first()
        )
        if cached:
            return WeatherCurrentResponse(
                latitude=latitude,
                longitude=longitude,
                timestamp=cached.recorded_at,
                temperature=cached.temperature,
                cloud_cover=cached.cloud_cover,
                relative_humidity=cached.relative_humidity,
                visibility=cached.visibility,
                wind_speed=cached.wind_speed,
                source="cache",
            )

        # Baseline fallback
        return WeatherCurrentResponse(
            latitude=latitude,
            longitude=longitude,
            timestamp=datetime.now(timezone.utc),
            temperature=14.5,
            cloud_cover=15.0,
            relative_humidity=58.0,
            visibility=12000.0,
            wind_speed=7.5,
            source="synthetic-model",
        )

    @staticmethod
    async def get_forecast(
        latitude: float,
        longitude: float,
        hours: int,
        db: Session,
    ) -> WeatherForecastResponse:
        url = (
            f"{settings.open_meteo_api_url}?"
            f"latitude={latitude}&longitude={longitude}&"
            "hourly=temperature_2m,relative_humidity_2m,cloud_cover&forecast_days=2"
        )
        hourly_items = []
        try:
            async with httpx.AsyncClient(timeout=3.5) as client:
                res = await client.get(url)
                if res.status_code == 200:
                    data = res.json().get("hourly", {})
                    times = data.get("time", [])[:hours]
                    temps = data.get("temperature_2m", [])[:hours]
                    clouds = data.get("cloud_cover", [])[:hours]
                    humidities = data.get("relative_humidity_2m", [])[:hours]
                    for i in range(len(times)):
                        hourly_items.append(
                            HourlyForecastItem(
                                time=times[i],
                                temperature=temps[i] if i < len(temps) else 15.0,
                                cloud_cover=clouds[i] if i < len(clouds) else 20.0,
                                humidity=humidities[i] if i < len(humidities) else 50.0,
                            )
                        )
                    return WeatherForecastResponse(
                        latitude=latitude,
                        longitude=longitude,
                        source="open-meteo",
                        hourly=hourly_items,
                    )
        except Exception as e:
            logger.warning(f"Could not load hourly forecast from Open-Meteo: {e}. Returning simulated curve.")

        now_hour = datetime.now(timezone.utc).hour
        for h in range(hours):
            sim_hour = (now_hour + h) % 24
            hourly_items.append(
                HourlyForecastItem(
                    time=f"+{h}h ({sim_hour:02d}:00)",
                    temperature=round(12.0 + 4.0 * (1 - abs(sim_hour - 14) / 14), 1),
                    cloud_cover=round(10.0 + (h % 5) * 5.0, 1),
                    humidity=round(55.0 + (h % 4) * 4.0, 1),
                )
            )

        return WeatherForecastResponse(
            latitude=latitude,
            longitude=longitude,
            source="synthetic-model",
            hourly=hourly_items,
        )

    @staticmethod
    async def evaluate_conditions(
        latitude: float,
        longitude: float,
        timestamp: Optional[datetime],
        db: Session,
    ) -> ObservationConditionsResponse:
        current = await WeatherService.get_current_weather(latitude, longitude, db)
        cloud = current.cloud_cover

        # Calculate astronomical observation score
        if cloud <= 15:
            score = 0.95
            rating = "EXCELLENT"
            summary = "Clear skies with minimal cloud interference, optimal transparency for deep-sky observation."
        elif cloud <= 35:
            score = 0.80
            rating = "GOOD"
            summary = "Mostly clear conditions. Minor passing clouds, great for planets and bright objects."
        elif cloud <= 65:
            score = 0.55
            rating = "FAIR"
            summary = "Partial cloud coverage. Useful for bright stars and Lunar observing, but faint targets may be obscured."
        else:
            score = 0.20
            rating = "POOR"
            summary = "Heavy cloud cover or overcast. Astronomical viewing is significantly obstructed."

        is_suitable = score >= 0.50
        obs_time = timestamp or datetime.now(timezone.utc)

        cond_record = ObservationConditions(
            latitude=latitude,
            longitude=longitude,
            timestamp=obs_time,
            cloud_cover=cloud,
            suitability_score=score,
            rating=rating,
            summary=summary,
        )
        db.add(cond_record)
        db.commit()

        return ObservationConditionsResponse(
            latitude=latitude,
            longitude=longitude,
            timestamp=obs_time,
            cloud_cover=cloud,
            suitability_score=score,
            rating=rating,
            is_suitable=is_suitable,
            summary=summary,
        )
