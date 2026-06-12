"""
GeminiService — LevelUp Creator AI Coach Engine
Powered by Google Gemini 1.5 Flash
"""
import google.generativeai as genai
from app.core.config import get_settings
from app.models.schemas import OnboardingData, InitialPlan, DailyMission

settings = get_settings()

# Configure Gemini
genai.configure(api_key=settings.gemini_api_key)

# Shared generation config
_GENERATION_CONFIG = genai.types.GenerationConfig(
    temperature=0.8,
    top_p=0.95,
    top_k=40,
    max_output_tokens=2048,
)

# Platform display names
PLATFORM_NAMES = {
    "tiktok": "TikTok",
    "instagram": "Instagram",
    "youtube": "YouTube",
    "twitch": "Twitch",
    "podcast": "Podcast",
    "linkedin": "LinkedIn",
    "twitter": "X (Twitter)",
}

# Niche display names
NICHE_NAMES = {
    "gaming": "Gaming & Entretenimiento / Gaming & Entertainment",
    "gastronomy": "Gastronomía & Lifestyle / Gastronomy & Lifestyle",
    "fashion": "Moda & Belleza / Fashion & Beauty",
    "finance": "Finanzas & Emprendimiento / Finance & Entrepreneurship",
    "fitness": "Fitness & Salud / Fitness & Health",
    "education": "Educación & Tutoriales / Education & Tutorials",
    "music": "Música & Arte / Music & Art",
    "travel": "Viajes & Aventura / Travel & Adventure",
    "technology": "Tecnología / Technology",
    "humor": "Humor & Comedia / Humor & Comedy",
    "pets": "Mascotas & Naturaleza / Pets & Nature",
    "home": "Hogar & Decoración / Home & Decoration",
}


def _get_coach_system_prompt(data: OnboardingData) -> str:
    """Build the personalized system prompt for the AI Coach."""
    platform = PLATFORM_NAMES.get(data.platform.value, data.platform.value)
    niche = NICHE_NAMES.get(data.niche.value, data.niche.value)
    lang = "Spanish" if data.language == "es" else "English"

    return f"""You are an expert AI Coach for content creators called "LevelUp Coach".
Your role is a personalized marketing consultant, strategic advisor, and motivational coach 
specialized in helping creators grow on social media from zero to success.

## User Profile
- Platform: {platform}
- Niche: {niche}
- Sub-niche: {data.sub_niche or "General"}
- Current followers: {data.followers_count}
- Publish frequency: {data.publish_frequency}
- Main fear/obstacle: {data.fear_type.value}
- Weekly available hours: {data.weekly_hours}h
- Best creation time: {data.best_time.value}
- Motivations: {", ".join([m.value for m in data.motivations])}
- 6-month goal: {data.goal_description}

## Your Coaching Style
- Always respond in {lang}
- Be direct, actionable, and encouraging
- Give specific advice for {platform}, not generic social media tips
- Tailor ALL content recommendations to the {niche} niche
- When the user seems frustrated, acknowledge their feelings first before giving advice
- Use emojis moderately to make responses feel warm and human
- Always end with a clear next action step

## Core Principles
1. Never promise specific follower numbers — focus on skills and habits
2. Platform-specific advice always (what works on TikTok ≠ Instagram ≠ YouTube)  
3. Celebrate small wins to maintain motivation
4. Explain the "why" behind every recommendation
5. If the user's main fear is {data.fear_type.value}, address it proactively and empathetically
"""


async def generate_initial_plan(data: OnboardingData) -> InitialPlan:
    """
    Generate a personalized initial coaching plan after onboarding.
    Called once when the user completes the onboarding flow.
    """
    model = genai.GenerativeModel(
        model_name="gemini-1.5-flash",
        generation_config=_GENERATION_CONFIG,
        system_instruction=_get_coach_system_prompt(data),
    )

    platform = PLATFORM_NAMES.get(data.platform.value, data.platform.value)
    niche = NICHE_NAMES.get(data.niche.value, data.niche.value)
    lang_instruction = "Respond in Spanish." if data.language == "es" else "Respond in English."

    # Determine level
    followers = data.followers_count
    if followers < 1000:
        level = 1
        level_name = "El Descubrimiento" if data.language == "es" else "The Discovery"
    elif followers < 10000:
        level = 2
        level_name = "El Micro-Influencer" if data.language == "es" else "The Micro-Influencer"
    elif followers < 100000:
        level = 3
        level_name = "El Profesional" if data.language == "es" else "The Professional"
    else:
        level = 4
        level_name = "La Celebridad" if data.language == "es" else "The Celebrity"

    prompt = f"""
    {lang_instruction}
    
    Create a personalized initial plan for a new user with this profile:
    - Platform: {platform}
    - Niche: {niche} (sub-niche: {data.sub_niche or "general"})
    - Current followers: {followers}
    - Level: {level} - {level_name}
    - Weekly hours available: {data.weekly_hours}h
    - Main fear: {data.fear_type.value}
    - Goal: {data.goal_description}

    Return a JSON object with EXACTLY this structure (no markdown, just JSON):
    {{
        "welcome_message": "A warm, personalized welcome message (2-3 sentences, mention their niche and platform)",
        "weekly_goal": "One specific, achievable goal for this first week on {platform} in the {niche} niche",
        "platform_strategy": "2-3 sentence strategy specific to {platform} for {niche} content",
        "niche_tips": [
            "Specific tip 1 for {niche} on {platform}",
            "Specific tip 2 for {niche} on {platform}",
            "Specific tip 3 for {niche} on {platform}"
        ],
        "first_content_idea": "One specific content idea they can create TODAY for {platform} in the {niche} niche",
        "daily_missions": [
            {{
                "title": "Mission 1 title",
                "description": "Detailed description of what to do",
                "platform_specific": true,
                "xp_reward": 50,
                "duration_minutes": 20,
                "difficulty": "easy",
                "tips": ["tip 1", "tip 2"]
            }},
            {{
                "title": "Mission 2 title",
                "description": "Detailed description of what to do",
                "platform_specific": true,
                "xp_reward": 75,
                "duration_minutes": 30,
                "difficulty": "medium",
                "tips": ["tip 1", "tip 2"]
            }},
            {{
                "title": "Mission 3 title",
                "description": "Detailed description of what to do",
                "platform_specific": false,
                "xp_reward": 100,
                "duration_minutes": 45,
                "difficulty": "medium",
                "tips": ["tip 1", "tip 2"]
            }}
        ]
    }}
    
    Make missions VERY specific to {platform} and {niche}. 
    Address the user's fear ({data.fear_type.value}) in at least one mission.
    The first_content_idea must be actionable TODAY with minimal equipment.
    """

    response = model.generate_content(prompt)
    
    import json
    text = response.text.strip()
    # Remove markdown code blocks if present
    if text.startswith("```"):
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]
    text = text.strip()

    plan_data = json.loads(text)

    missions = [DailyMission(**m) for m in plan_data["daily_missions"]]

    return InitialPlan(
        level_assigned=level,
        level_name=level_name,
        welcome_message=plan_data["welcome_message"],
        weekly_goal=plan_data["weekly_goal"],
        daily_missions=missions,
        platform_strategy=plan_data["platform_strategy"],
        niche_tips=plan_data["niche_tips"],
        first_content_idea=plan_data["first_content_idea"],
    )


async def chat_with_coach(
    user_message: str,
    user_profile: dict,
    conversation_history: list[dict],
    language: str = "es",
) -> dict:
    """
    Stream a response from the AI Coach based on user message and history.
    """
    # Build a lightweight onboarding-like object for system prompt
    from app.models.schemas import Platform, Niche, Fear, BestTime, Motivation

    platform_str = user_profile.get("platform", "tiktok")
    niche_str = user_profile.get("niche", "gaming")
    lang = language

    platform_name = PLATFORM_NAMES.get(platform_str, platform_str)
    niche_name = NICHE_NAMES.get(niche_str, niche_str)
    lang_instruction = "Always respond in Spanish." if lang == "es" else "Always respond in English."

    system_prompt = f"""You are LevelUp Coach, an expert AI coach for content creators.
{lang_instruction}

## User's Profile
- Platform: {platform_name}
- Niche: {niche_name}
- Level: {user_profile.get('current_level', 1)}
- Followers: {user_profile.get('followers_count', 0)}
- XP: {user_profile.get('total_xp', 0)}
- Current streak: {user_profile.get('current_streak', 0)} days

## Your Style
- Be warm, direct, and actionable
- Always give platform-specific advice for {platform_name}
- Address {niche_name} content specifics
- Celebrate progress and normalize setbacks
- End with a clear next action step
- Use emojis moderately
"""

    model = genai.GenerativeModel(
        model_name="gemini-1.5-flash",
        generation_config=genai.types.GenerationConfig(
            temperature=0.85,
            top_p=0.95,
            max_output_tokens=1024,
        ),
        system_instruction=system_prompt,
    )

    # Build conversation history for Gemini
    history = []
    for msg in conversation_history[-10:]:  # last 10 messages for context
        history.append({
            "role": "user" if msg["role"] == "user" else "model",
            "parts": [msg["content"]],
        })

    chat = model.start_chat(history=history)
    response = chat.send_message(user_message)

    # Determine conversation type
    lower_msg = user_message.lower()
    if any(word in lower_msg for word in ["triste", "mal", "frustrado", "rendirse", "sad", "frustrated", "quit", "give up"]):
        conv_type = "emotional"
    elif any(word in lower_msg for word in ["guión", "script", "idea", "contenido", "content", "video", "post"]):
        conv_type = "content"
    elif any(word in lower_msg for word in ["estrategia", "strategy", "algoritmo", "algorithm", "crecimiento", "growth"]):
        conv_type = "strategy"
    else:
        conv_type = "general"

    return {
        "response": response.text,
        "conversation_type": conv_type,
    }


async def generate_content_script(
    topic: str,
    platform: str,
    niche: str,
    tone: str,
    duration_seconds: int,
    language: str = "es",
) -> str:
    """Generate a video script adapted to platform and niche."""
    platform_name = PLATFORM_NAMES.get(platform, platform)
    niche_name = NICHE_NAMES.get(niche, niche)
    lang_instruction = "Write in Spanish." if language == "es" else "Write in English."

    model = genai.GenerativeModel(model_name="gemini-1.5-flash")

    prompt = f"""
    {lang_instruction}
    
    Create a {duration_seconds}-second video script for {platform_name} in the {niche_name} niche.
    Topic: {topic}
    Tone: {tone}
    
    Structure:
    🎯 HOOK (first 2-3 seconds): [attention-grabbing opening]
    📖 DEVELOPMENT (middle): [main content]
    🚀 CTA (last 3-5 seconds): [call to action]
    
    Make it conversational, natural, and specific to {platform_name}.
    Include stage directions in [brackets] where needed.
    """

    response = model.generate_content(prompt)
    return response.text


async def generate_caption(
    topic: str,
    platform: str,
    niche: str,
    tone: str,
    include_hashtags: bool,
    language: str = "es",
) -> str:
    """Generate an optimized caption/description for a post."""
    platform_name = PLATFORM_NAMES.get(platform, platform)
    niche_name = NICHE_NAMES.get(niche, niche)
    lang_instruction = "Write in Spanish." if language == "es" else "Write in English."

    hashtag_instruction = f"Include 10-15 relevant hashtags for {platform_name} in the {niche_name} niche." if include_hashtags else "Do NOT include hashtags."

    model = genai.GenerativeModel(model_name="gemini-1.5-flash")

    prompt = f"""
    {lang_instruction}
    
    Write an optimized {platform_name} caption for a {niche_name} post.
    Topic: {topic}
    Tone: {tone}
    
    Requirements:
    - Hook in the first line (this is what people see before clicking "more")
    - Engaging body with value
    - Clear CTA at the end
    - {hashtag_instruction}
    - Adapted to {platform_name}'s style and character limits
    """

    response = model.generate_content(prompt)
    return response.text


async def generate_content_ideas(
    platform: str,
    niche: str,
    sub_niche: str,
    language: str = "es",
) -> list[dict]:
    """Generate 3 trending content ideas for the user's platform and niche."""
    platform_name = PLATFORM_NAMES.get(platform, platform)
    niche_name = NICHE_NAMES.get(niche, niche)
    lang_instruction = "Respond in Spanish." if language == "es" else "Respond in English."

    model = genai.GenerativeModel(model_name="gemini-1.5-flash")

    prompt = f"""
    {lang_instruction}
    
    Generate 3 specific content ideas for a creator on {platform_name} in the {niche_name} niche
    (sub-niche: {sub_niche or "general"}).
    
    Return a JSON array with EXACTLY this structure (no markdown, just JSON):
    [
        {{
            "title": "Catchy title for the content",
            "format": "Specific format (e.g., '30-second Reel', '8-minute YouTube video', 'TikTok series')",
            "hook": "The exact first sentence/frame to grab attention",
            "why_it_works": "1 sentence explaining the viral potential",
            "estimated_time": "Time to create this content"
        }},
        ...
    ]
    
    Make ideas VERY specific and actionable for {platform_name} in {niche_name}.
    Ideas should be achievable with a smartphone and basic tools.
    """

    response = model.generate_content(prompt)
    text = response.text.strip()
    if text.startswith("```"):
        text = text.split("```")[1]
        if text.startswith("json"):
            text = text[4:]
    text = text.strip()

    import json
    return json.loads(text)
