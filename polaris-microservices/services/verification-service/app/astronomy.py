import math
from datetime import datetime, timezone


def calculate_altitude(latitude: float, longitude: float, ra_deg: float, dec_deg: float, obs_time: datetime) -> float:
    """Calculate celestial object's altitude above horizon in degrees.

    :param latitude: Observer latitude in degrees (-90 to +90)
    :param longitude: Observer longitude in degrees (-180 to +180)
    :param ra_deg: Object Right Ascension in degrees (0 to 360)
    :param dec_deg: Object Declination in degrees (-90 to +90)
    :param obs_time: UTC datetime of observation
    :return: Altitude above horizon in degrees (-90 to +90)
    """
    if obs_time.tzinfo is None:
        obs_time = obs_time.replace(tzinfo=timezone.utc)
    else:
        obs_time = obs_time.astimezone(timezone.utc)

    # Convert to Julian Date
    timestamp = obs_time.timestamp()
    jd = timestamp / 86400.0 + 2440587.5
    d = jd - 2451545.0  # Days since J2000.0

    # Greenwich Mean Sidereal Time in degrees
    gmst = (280.46061837 + 360.98564736629 * d) % 360.0

    # Local Sidereal Time in degrees
    lst = (gmst + longitude) % 360.0

    # Hour Angle in radians
    ha_deg = (lst - ra_deg) % 360.0
    ha_rad = math.radians(ha_deg)

    lat_rad = math.radians(latitude)
    dec_rad = math.radians(dec_deg)

    sin_alt = math.sin(lat_rad) * math.sin(dec_rad) + math.cos(lat_rad) * math.cos(dec_rad) * math.cos(ha_rad)
    sin_alt = max(-1.0, min(1.0, sin_alt))
    alt_rad = math.asin(sin_alt)

    return math.degrees(alt_rad)
