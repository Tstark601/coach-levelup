from fastapi import APIRouter, HTTPException, Depends, status
from app.models.schemas import OnboardingData, OnboardingResponse, UserProfile
from app.services.gemini_service import generate_initial_plan
from app.db.supabase_client import get_supabase_admin
from app.core.dependencies import get_current_user_id

router = APIRouter(prefix="/onboarding", tags=["Onboarding"])


@router.post("/complete", response_model=OnboardingResponse)
async def complete_onboarding(
    data: OnboardingData,
    auth_id: str = Depends(get_current_user_id),
):
    """
    Complete the onboarding flow:
    1. Save user profile to Supabase
    2. Generate personalized initial plan with Gemini
    3. Return profile + plan
    """
    supabase = get_supabase_admin()

    # Check if user profile already exists
    existing = supabase.table("users").select("id").eq("auth_id", auth_id).execute()
    if existing.data:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Onboarding already completed for this user.",
        )

    # Determine initial level based on followers
    followers = data.followers_count
    if followers < 1000:
        level = 1
    elif followers < 10000:
        level = 2
    elif followers < 100000:
        level = 3
    else:
        level = 4

    # Save user profile
    user_data = {
        "auth_id": auth_id,
        "username": data.username,
        "niche": data.niche.value,
        "sub_niche": data.sub_niche,
        "target_audience": data.target_audience,
        "age_range": data.age_range,
        "platform": data.platform.value,
        "secondary_platform": data.secondary_platform.value if data.secondary_platform else None,
        "current_level": level,
        "total_xp": 0,
        "followers_count": data.followers_count,
        "weekly_hours": data.weekly_hours,
        "best_time": data.best_time.value,
        "motivation": data.motivations,
        "goal_description": data.goal_description,
        "fear_type": data.fear_type.value,
        "publish_frequency": data.publish_frequency,
        "onboarding_completed": True,
        "language": data.language,
        "current_streak": 0,
        "longest_streak": 0,
    }

    result = supabase.table("users").insert(user_data).execute()
    if not result.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to save user profile.",
        )

    saved_profile = result.data[0]

    # Generate personalized plan with Gemini
    try:
        initial_plan = await generate_initial_plan(data)
    except Exception as e:
        # If Gemini fails, still return the profile
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Profile saved but plan generation failed: {str(e)}",
        )

    return OnboardingResponse(
        success=True,
        user_profile=UserProfile(**saved_profile),
        initial_plan=initial_plan,
    )


@router.get("/status")
async def get_onboarding_status(auth_id: str = Depends(get_current_user_id)):
    """Check if the current user has completed onboarding."""
    supabase = get_supabase_admin()
    result = supabase.table("users").select("onboarding_completed, username").eq("auth_id", auth_id).execute()

    if not result.data:
        return {"completed": False, "username": None}

    user = result.data[0]
    return {
        "completed": user.get("onboarding_completed", False),
        "username": user.get("username"),
    }
