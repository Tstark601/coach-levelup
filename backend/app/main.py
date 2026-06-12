"""
LevelUp Creator — FastAPI Backend
AI-powered coaching platform for content creators
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import get_settings
from app.api.v1 import onboarding, users, coach, missions

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="🎞️ LevelUp Creator — AI Coach API for content creators",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(onboarding.router, prefix="/api/v1")
app.include_router(users.router, prefix="/api/v1")
app.include_router(coach.router, prefix="/api/v1")
app.include_router(missions.router, prefix="/api/v1")


@app.get("/", tags=["Health"])
async def root():
    return {
        "app": settings.app_name,
        "version": settings.app_version,
        "status": "🟢 Running",
        "docs": "/docs",
    }


@app.get("/health", tags=["Health"])
async def health_check():
    return {"status": "healthy", "env": settings.app_env}
