from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # App
    app_name: str = "LevelUp Creator API"
    app_version: str = "1.0.0"
    app_env: str = "development"
    app_port: int = 5000
    app_secret_key: str = "change-me-in-production"
    cors_origins: str = "http://localhost:3000"

    # Supabase
    supabase_url: str
    supabase_anon_key: str
    supabase_service_role_key: str
    supabase_jwt_secret: str

    # Google Gemini
    gemini_api_key: str

    # Firebase
    firebase_credentials_path: str = "firebase-credentials.json"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"

    @property
    def cors_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",")]


@lru_cache()
def get_settings() -> Settings:
    return Settings()
