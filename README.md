# 🎞️ LevelUp Creator

> **AI-powered coaching app for content creators**
> Flutter · FastAPI · Supabase (PostgreSQL) · Google Gemini 1.5 Flash

---

## 📁 Project Structure

```
coach_influ/
├── 📱 mobile/          # Flutter App (iOS + Android)
├── 🐍 backend/         # FastAPI Backend
└── 📄 docs/            # Database schema & documentation
```

## 🚀 Quick Start

### 1. Backend Setup

```powershell
cd backend
# Create virtual environment
python -m venv venv
.\venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment variables
copy .env.example .env
# Edit .env with your Supabase and Gemini API keys

# Run the backend on port 5000
uvicorn app.main:app --reload --host 0.0.0.0 --port 5000

# Or use the shortcut script:
# .\run.bat
```

API docs available at: http://localhost:8000/docs

### 2. Database Setup (Supabase)

1. Create a new project at https://supabase.com
2. Go to SQL Editor
3. Run the schema from `docs/db_schema.sql`

### 3. Flutter App Setup

```powershell
cd mobile
# Install dependencies
flutter pub get

# Configure Supabase (in lib/main.dart)
# Replace YOUR_SUPABASE_URL and YOUR_SUPABASE_ANON_KEY

# Run the app
flutter run
```

## 🔑 Required API Keys

| Service | Where to get |
|---------|-------------|
| Supabase URL + Anon Key | https://supabase.com → Project Settings → API |
| Supabase Service Role Key | https://supabase.com → Project Settings → API |
| Supabase JWT Secret | https://supabase.com → Project Settings → API |
| Google Gemini API Key | https://aistudio.google.com → Get API Key |

## 🎮 Features (Phase 1)
- ✅ Email + Google authentication
- ✅ 6-step personalized onboarding
- ✅ Platform + Niche selection (core axes)
- ✅ AI-generated initial plan (Gemini 1.5 Flash)
- ✅ Dashboard with XP and level system
- ✅ AI Coach chat interface
- ✅ Daily missions system
- ✅ Content script generator
- ✅ Caption & hashtag generator

## 🏗️ Architecture
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **HTTP Client**: Dio
- **Auth**: Supabase Auth (Email + Google OAuth)
- **Database**: Supabase PostgreSQL with Row Level Security
- **AI**: Google Gemini 1.5 Flash
