from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum


# ─── Enums ───────────────────────────────────────────────────────────────────

class Platform(str, Enum):
    tiktok = "tiktok"
    instagram = "instagram"
    youtube = "youtube"
    twitch = "twitch"
    podcast = "podcast"
    linkedin = "linkedin"
    twitter = "twitter"


class Niche(str, Enum):
    gaming = "gaming"
    gastronomy = "gastronomy"
    fashion = "fashion"
    finance = "finance"
    fitness = "fitness"
    education = "education"
    music = "music"
    travel = "travel"
    technology = "technology"
    humor = "humor"
    pets = "pets"
    home = "home"


class Fear(str, Enum):
    camera = "camera"
    editing = "editing"
    ideas = "ideas"
    consistency = "consistency"
    everything = "everything"


class Motivation(str, Enum):
    fame = "fame"
    income = "income"
    impact = "impact"
    community = "community"
    learning = "learning"


class BestTime(str, Enum):
    early_morning = "early_morning"
    midday = "midday"
    afternoon = "afternoon"
    night = "night"
    variable = "variable"


# ─── User Schemas ─────────────────────────────────────────────────────────────

class UserCreate(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    email: str


class UserProfile(BaseModel):
    id: str
    auth_id: str
    username: str
    niche: Optional[str] = None
    sub_niche: Optional[str] = None
    target_audience: Optional[str] = None
    age_range: Optional[str] = None
    platform: Optional[str] = None
    secondary_platform: Optional[str] = None
    current_level: int = 1
    total_xp: int = 0
    followers_count: int = 0
    weekly_hours: int = 3
    best_time: Optional[str] = None
    motivation: Optional[list[str]] = None
    goal_description: Optional[str] = None
    fear_type: Optional[str] = None
    current_streak: int = 0
    longest_streak: int = 0
    onboarding_completed: bool = False
    language: str = "es"


class UserStats(BaseModel):
    current_level: int
    total_xp: int
    xp_to_next_level: int
    current_streak: int
    longest_streak: int
    followers_count: int
    missions_completed: int
    badges_earned: int


# ─── Onboarding Schemas ───────────────────────────────────────────────────────

class OnboardingData(BaseModel):
    username: str = Field(..., min_length=3, max_length=50)
    platform: Platform
    secondary_platform: Optional[Platform] = None
    niche: Niche
    sub_niche: Optional[str] = Field(None, max_length=100)
    target_audience: Optional[str] = Field(None, max_length=100)
    age_range: Optional[str] = Field(None, max_length=50)
    followers_count: int = Field(0, ge=0)
    publish_frequency: str  # 'never' | 'rarely' | 'weekly' | 'several' | 'daily'
    fear_type: Fear
    weekly_hours: int = Field(3, ge=0, le=168)
    best_time: BestTime
    motivations: list[Motivation]
    goal_description: str = Field(..., max_length=150)
    language: str = Field("es", pattern="^(es|en)$")


class OnboardingResponse(BaseModel):
    success: bool
    user_profile: UserProfile
    initial_plan: "InitialPlan"


# ─── Plan & Mission Schemas ───────────────────────────────────────────────────

class DailyMission(BaseModel):
    title: str
    description: str
    platform_specific: bool
    xp_reward: int
    duration_minutes: int
    difficulty: str  # 'easy' | 'medium' | 'hard'
    tips: list[str]


class InitialPlan(BaseModel):
    level_assigned: int
    level_name: str
    welcome_message: str
    weekly_goal: str
    daily_missions: list[DailyMission]
    platform_strategy: str
    niche_tips: list[str]
    first_content_idea: str


# ─── Coach Chat Schemas ───────────────────────────────────────────────────────

class ChatMessage(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000)
    language: str = Field("es", pattern="^(es|en)$")


class ChatResponse(BaseModel):
    response: str
    conversation_type: str  # 'strategy' | 'emotional' | 'content' | 'general'


# ─── Content Generation Schemas ───────────────────────────────────────────────

class ScriptRequest(BaseModel):
    topic: str = Field(..., max_length=200)
    tone: str = Field("motivational", pattern="^(funny|educational|serious|motivational)$")
    duration_seconds: int = Field(60, ge=15, le=3600)
    language: str = Field("es", pattern="^(es|en)$")


class CaptionRequest(BaseModel):
    topic: str = Field(..., max_length=200)
    tone: str = Field("motivational")
    include_hashtags: bool = True
    language: str = Field("es", pattern="^(es|en)$")


class ContentIdeasRequest(BaseModel):
    language: str = Field("es", pattern="^(es|en)$")


class GeneratedContent(BaseModel):
    content_type: str
    generated_text: str
    tips: Optional[list[str]] = None
