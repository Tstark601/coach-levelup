from fastapi import APIRouter, Depends
from fastapi.responses import StreamingResponse
from app.models.schemas import ChatMessage, ContentIdeasRequest, ScriptRequest, CaptionRequest
from app.services import gemini_service
from app.db.supabase_client import get_supabase_admin
from app.core.dependencies import get_current_user
import json

router = APIRouter(prefix="/coach", tags=["Coach AI"])


@router.post("/chat")
async def chat_with_coach(
    payload: ChatMessage,
    user: dict = Depends(get_current_user),
):
    """Send a message to the AI Coach and get a response."""
    supabase = get_supabase_admin()

    # Load recent conversation history
    history_result = (
        supabase.table("ai_conversations")
        .select("role, content")
        .eq("user_id", user["id"])
        .eq("conversation_type", "chat")
        .order("created_at", desc=True)
        .limit(20)
        .execute()
    )
    history = list(reversed(history_result.data or []))

    # Get AI response
    result = await gemini_service.chat_with_coach(
        user_message=payload.message,
        user_profile=user,
        conversation_history=history,
        language=payload.language,
    )

    # Save both messages to DB
    supabase.table("ai_conversations").insert([
        {
            "user_id": user["id"],
            "role": "user",
            "content": payload.message,
            "conversation_type": result["conversation_type"],
        },
        {
            "user_id": user["id"],
            "role": "assistant",
            "content": result["response"],
            "conversation_type": result["conversation_type"],
        },
    ]).execute()

    return result


@router.get("/history")
async def get_chat_history(
    limit: int = 50,
    user: dict = Depends(get_current_user),
):
    """Return recent chat history with the AI Coach."""
    supabase = get_supabase_admin()
    result = (
        supabase.table("ai_conversations")
        .select("role, content, conversation_type, created_at")
        .eq("user_id", user["id"])
        .order("created_at", desc=False)
        .limit(limit)
        .execute()
    )
    return {"messages": result.data or []}


@router.post("/generate-plan")
async def regenerate_plan(
    user: dict = Depends(get_current_user),
):
    """Regenerate the personalized coaching plan for the current user."""
    from app.models.schemas import (
        OnboardingData, Platform, Niche, Fear, BestTime, Motivation
    )

    # Reconstruct OnboardingData from saved profile
    motivations_raw = user.get("motivation") or ["impact"]
    motivations = [Motivation(m) for m in motivations_raw if m in [e.value for e in Motivation]]

    data = OnboardingData(
        username=user["username"],
        platform=Platform(user.get("platform", "tiktok")),
        niche=Niche(user.get("niche", "gaming")),
        sub_niche=user.get("sub_niche"),
        followers_count=user.get("followers_count", 0),
        publish_frequency=user.get("publish_frequency", "rarely"),
        fear_type=Fear(user.get("fear_type", "camera")),
        weekly_hours=user.get("weekly_hours", 3),
        best_time=BestTime(user.get("best_time", "afternoon")),
        motivations=motivations,
        goal_description=user.get("goal_description", "Grow my audience"),
        language=user.get("language", "es"),
    )

    plan = await gemini_service.generate_initial_plan(data)
    return plan


@router.post("/content/script")
async def generate_script(
    payload: ScriptRequest,
    user: dict = Depends(get_current_user),
):
    """Generate a video script for the user's platform and niche."""
    script = await gemini_service.generate_content_script(
        topic=payload.topic,
        platform=user.get("platform", "tiktok"),
        niche=user.get("niche", "gaming"),
        tone=payload.tone,
        duration_seconds=payload.duration_seconds,
        language=payload.language,
    )

    # Save generated content
    supabase = get_supabase_admin()
    supabase.table("generated_content").insert({
        "user_id": user["id"],
        "content_type": "script",
        "niche": user.get("niche"),
        "platform": user.get("platform"),
        "prompt_used": payload.topic,
        "generated_text": script,
        "tone": payload.tone,
    }).execute()

    return {"script": script}


@router.post("/content/caption")
async def generate_caption(
    payload: CaptionRequest,
    user: dict = Depends(get_current_user),
):
    """Generate an optimized caption for a post."""
    caption = await gemini_service.generate_caption(
        topic=payload.topic,
        platform=user.get("platform", "instagram"),
        niche=user.get("niche", "gaming"),
        tone=payload.tone,
        include_hashtags=payload.include_hashtags,
        language=payload.language,
    )

    supabase = get_supabase_admin()
    supabase.table("generated_content").insert({
        "user_id": user["id"],
        "content_type": "caption",
        "niche": user.get("niche"),
        "platform": user.get("platform"),
        "prompt_used": payload.topic,
        "generated_text": caption,
        "tone": payload.tone,
    }).execute()

    return {"caption": caption}


@router.post("/content/ideas")
async def get_content_ideas(
    payload: ContentIdeasRequest,
    user: dict = Depends(get_current_user),
):
    """Get 3 trending content ideas for the user's platform and niche."""
    ideas = await gemini_service.generate_content_ideas(
        platform=user.get("platform", "tiktok"),
        niche=user.get("niche", "gaming"),
        sub_niche=user.get("sub_niche", ""),
        language=payload.language,
    )
    return {"ideas": ideas}
