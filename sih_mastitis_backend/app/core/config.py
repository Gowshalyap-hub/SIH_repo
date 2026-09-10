from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "SIH Mastitis Backend API"
    DATABASE_URL: str = "sqlite:///./sih_mastitis.db"
    SECRET_KEY: str = "super_secret_key_change_me_in_production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7 # 7 days
    
    # MQTT
    MQTT_BROKER_HOST: str = "test.mosquitto.org"
    MQTT_BROKER_PORT: int = 1883
    MQTT_USERNAME: str = ""
    MQTT_PASSWORD: str = ""
    MQTT_CLIENT_ID: str = "sih_mastitis_backend"
    FINAL_MASTITIS_TOPIC: str = "sih/mastitis/cow/data"

    class Config:
        env_file = ".env"

settings = Settings()
