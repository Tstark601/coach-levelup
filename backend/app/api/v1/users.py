from fastapi import APIRouter, HTTPException, Depends
from app.models.schemas import UserProfile, UserStats
from app.db.supabase_client import get_supabase_admin
from app.core.dependencies import get_current_user_id, get_current_user

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserProfile)
async def get_my_profile(user: dict = Depends(get_current_user)):
    """Return the current user's full profile."""
    return UserProfile(**user)


@router.patch("/me")
async def update_profile(
    updates: dict,
    auth_id: str = Depends(get_current_user_id),
):
    """Update allowed profile fields."""
    ALLOWED_FIELDS = {"username", "goal_description", "weekly_hours", "best_time", "language"}
    filtered = {k: v for k, v in updates.items() if k in ALLOWED_FIELDS}

    if not filtered:
        raise HTTPException(status_code=400, detail="No valid fields to update.")

    supabase = get_supabase_admin()
    result = (
        supabase.table("users")
        .update(filtered)
        .eq("auth_id", auth_id)
        .execute()
    )
    return {"success": True, "updated": filtered}


@router.patch("/me/followers")
async def update_followers(
    payload: dict,
    auth_id: str = Depends(get_current_user_id),
):
    """Update follower count — triggers level recalculation."""
    followers = payload.get("followers_count")
    if followers is None or not isinstance(followers, int) or followers < 0:
        raise HTTPException(status_code=400, detail="Invalid followers_count value.")

    # Recalculate level
    if followers < 1000:
        new_level = 1
    elif followers < 10000:
        new_level = 2
    elif followers < 100000:
        new_level = 3
    else:
        new_level = 4

    supabase = get_supabase_admin()
    supabase.table("users").update({
        "followers_count": followers,
        "current_level": new_level,
    }).eq("auth_id", auth_id).execute()

    # Log the update
    user_result = supabase.table("users").select("id").eq("auth_id", auth_id).single().execute()
    if user_result.data:
        supabase.table("progress_logs").insert({
            "user_id": user_result.data["id"],
            "log_type": "followers_update",
            "value": followers,
            "description": f"Followers updated to {followers} — Level {new_level}",
        }).execute()

    return {"success": True, "followers_count": followers, "current_level": new_level}


@router.get("/me/stats", response_model=UserStats)
async def get_my_stats(user: dict = Depends(get_current_user)):
    """Return XP, level, streaks and mission stats."""
    supabase = get_supabase_admin()

    # Count completed missions
    missions_result = (
        supabase.table("user_missions")
        .select("id", count="exact")
        .eq("user_id", user["id"])
        .eq("status", "completed")
        .execute()
    )
    missions_completed = missions_result.count or 0

    # Count badges
    badges_result = (
        supabase.table("achievements")
        .select("id", count="exact")
        .eq("user_id", user["id"])
        .execute()
    )
    badges_earned = badges_result.count or 0

    # XP thresholds per level
    xp_thresholds = {1: 500, 2: 2000, 3: 10000, 4: 99999}
    current_level = user.get("current_level", 1)
    xp_to_next = xp_thresholds.get(current_level, 99999) - user.get("total_xp", 0)

    return UserStats(
        current_level=current_level,
        total_xp=user.get("total_xp", 0),
        xp_to_next_level=max(0, xp_to_next),
        current_streak=user.get("current_streak", 0),
        longest_streak=user.get("longest_streak", 0),
        followers_count=user.get("followers_count", 0),
        missions_completed=missions_completed,
        badges_earned=badges_earned,
    )
