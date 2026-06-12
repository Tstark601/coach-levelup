from jose import jwt, JWTError
from fastapi import HTTPException, status
from app.core.config import get_settings

settings = get_settings()


def verify_supabase_jwt(token: str) -> dict:
    """Verify a Supabase-issued JWT token and return its payload."""
    try:
        payload = jwt.decode(
            token,
            settings.supabase_jwt_secret,
            algorithms=["HS256"],
            options={"verify_aud": False},
        )
        return payload
    except JWTError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid authentication token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )


def extract_user_id(payload: dict) -> str:
    """Extract the user UUID from a decoded JWT payload."""
    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token missing user identifier",
        )
    return user_id
