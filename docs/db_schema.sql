-- ============================================================
-- LevelUp Creator — Supabase Database Schema
-- Run this in your Supabase SQL Editor
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── Table: users ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.users (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id             UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  username            VARCHAR(50) UNIQUE NOT NULL,
  niche               VARCHAR(50) NOT NULL,
  sub_niche           VARCHAR(100),
  platform            VARCHAR(30) NOT NULL,
  secondary_platform  VARCHAR(30),
  current_level       INTEGER DEFAULT 1 CHECK (current_level BETWEEN 1 AND 4),
  total_xp            INTEGER DEFAULT 0,
  followers_count     INTEGER DEFAULT 0,
  weekly_hours        INTEGER DEFAULT 3,
  best_time           VARCHAR(30),
  motivation          TEXT[],
  goal_description    TEXT,
  fear_type           VARCHAR(50),
  publish_frequency   VARCHAR(30),
  onboarding_completed BOOLEAN DEFAULT FALSE,
  language            VARCHAR(5) DEFAULT 'es',
  current_streak      INTEGER DEFAULT 0,
  longest_streak      INTEGER DEFAULT 0,
  created_at          TIMESTAMPTZ DEFAULT NOW(),
  updated_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Table: missions ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.missions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title           VARCHAR(200) NOT NULL,
  description     TEXT NOT NULL,
  mission_type    VARCHAR(30) NOT NULL CHECK (mission_type IN ('daily', 'weekly', 'special')),
  level_required  INTEGER NOT NULL CHECK (level_required BETWEEN 1 AND 4),
  platform        VARCHAR(30),
  niche           VARCHAR(50),
  xp_reward       INTEGER NOT NULL,
  badge_reward    VARCHAR(50),
  duration_days   INTEGER DEFAULT 1,
  difficulty      VARCHAR(20) DEFAULT 'medium',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Table: user_missions ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_missions (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES public.users(id) ON DELETE CASCADE,
  mission_id    UUID REFERENCES public.missions(id),
  status        VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'failed', 'skipped')),
  progress      INTEGER DEFAULT 0 CHECK (progress BETWEEN 0 AND 100),
  assigned_at   TIMESTAMPTZ DEFAULT NOW(),
  completed_at  TIMESTAMPTZ,
  notes         TEXT
);

-- ─── Table: ai_conversations ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.ai_conversations (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             UUID REFERENCES public.users(id) ON DELETE CASCADE,
  session_id          UUID DEFAULT gen_random_uuid(),
  role                VARCHAR(10) NOT NULL CHECK (role IN ('user', 'assistant')),
  content             TEXT NOT NULL,
  conversation_type   VARCHAR(30) DEFAULT 'chat' CHECK (conversation_type IN ('chat', 'onboarding', 'feedback', 'emotional', 'strategy', 'content', 'general')),
  created_at          TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Table: content_evaluations ──────────────────────────────
CREATE TABLE IF NOT EXISTS public.content_evaluations (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID REFERENCES public.users(id) ON DELETE CASCADE,
  content_url       TEXT,
  content_type      VARCHAR(20) NOT NULL CHECK (content_type IN ('video', 'image', 'carousel')),
  hook_score        INTEGER CHECK (hook_score BETWEEN 1 AND 10),
  visual_score      INTEGER CHECK (visual_score BETWEEN 1 AND 10),
  audio_score       INTEGER CHECK (audio_score BETWEEN 1 AND 10),
  cta_score         INTEGER CHECK (cta_score BETWEEN 1 AND 10),
  niche_alignment   INTEGER CHECK (niche_alignment BETWEEN 1 AND 10),
  overall_score     DECIMAL(3,1),
  feedback_text     TEXT,
  suggestions       JSONB,
  evaluated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Table: achievements ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.achievements (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES public.users(id) ON DELETE CASCADE,
  badge_name    VARCHAR(100) NOT NULL,
  badge_type    VARCHAR(50) NOT NULL CHECK (badge_type IN ('level', 'streak', 'mission', 'special')),
  description   TEXT,
  icon_url      TEXT,
  earned_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Table: progress_logs ────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.progress_logs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID REFERENCES public.users(id) ON DELETE CASCADE,
  log_type      VARCHAR(50) NOT NULL CHECK (log_type IN ('xp_gain', 'level_up', 'streak_update', 'followers_update', 'mission_complete')),
  value         INTEGER NOT NULL,
  description   TEXT,
  logged_at     TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Table: generated_content ────────────────────────────────
CREATE TABLE IF NOT EXISTS public.generated_content (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES public.users(id) ON DELETE CASCADE,
  content_type    VARCHAR(30) NOT NULL CHECK (content_type IN ('script', 'caption', 'hashtags', 'title', 'ideas')),
  niche           VARCHAR(50),
  platform        VARCHAR(30),
  prompt_used     TEXT,
  generated_text  TEXT NOT NULL,
  tone            VARCHAR(30),
  is_saved        BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── Indexes ─────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_users_auth_id ON public.users(auth_id);
CREATE INDEX IF NOT EXISTS idx_user_missions_user_id ON public.user_missions(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_id ON public.ai_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_logs_user_id ON public.progress_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_generated_content_user_id ON public.generated_content(user_id);

-- ─── Row Level Security ───────────────────────────────────────
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.progress_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.generated_content ENABLE ROW LEVEL SECURITY;

-- Users can only read/update their own data
CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = auth_id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = auth_id);

-- Missions table is publicly readable (no sensitive data)
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Missions are publicly readable" ON public.missions
  FOR SELECT USING (true);

-- ─── Updated_at trigger ───────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
