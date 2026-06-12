from supabase import create_client, Client
from functools import lru_cache
from app.core.config import get_settings

settings = get_settings()


@lru_cache()
def get_supabase_anon() -> Client:
    """Supabase client with anon key — for public operations."""
    return create_client(settings.supabase_url, settings.supabase_anon_key)


@lru_cache()
def get_supabase_admin() -> Client:
    """Supabase client with service role key — for admin/backend operations."""
    return create_client(settings.supabase_url, settings.supabase_service_role_key)
