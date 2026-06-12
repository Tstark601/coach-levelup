from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from app.core.security import verify_supabase_jwt, extract_user_id
from app.db.supabase_client import get_supabase_admin

security = HTTPBearer()


async def get_current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> str:
    """FastAPI dependency: extracts and validates user ID from Bearer token."""
    token = credentials.credentials
    payload = verify_supabase_jwt(token)
    return extract_user_id(payload)


async def get_current_user(
    user_id: str = Depends(get_current_user_id),
) -> dict:
    """FastAPI dependency: returns the full user profile from Supabase."""
    supabase = get_supabase_admin()
    result = supabase.table("users").select("*").eq("auth_id", user_id).single().execute()
    if not result.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found. Please complete registration.",
        )
    return result.data
