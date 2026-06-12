class AppConstants {
  AppConstants._();

  // ─── API ────────────────────────────────────────────────
  // URL local para pruebas:
  // static const String apiBaseUrl = 'http://localhost:5000/api/v1'; 
  
  // URL de producción (Render):
  static const String apiBaseUrl = 'https://coach-influ-backend.onrender.com/api/v1';

  // ─── Supabase ────────────────────────────────────────────
  // These will be loaded from environment in production
  static const String supabaseUrl = 'https://orbgdopeictvhjscaucd.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_8I0wwvbpX3m6EjcGZo5pew_kZG6K7qO';

  // ─── XP Thresholds ───────────────────────────────────────
  static const Map<int, int> xpToLevelUp = {
    1: 500,
    2: 2000,
    3: 10000,
    4: 99999,
  };

  // ─── Level Names ─────────────────────────────────────────
  static const Map<int, String> levelNamesEs = {
    1: 'El Descubrimiento',
    2: 'El Micro-Influencer',
    3: 'El Profesional',
    4: 'La Celebridad',
  };

  static const Map<int, String> levelNamesEn = {
    1: 'The Discovery',
    2: 'The Micro-Influencer',
    3: 'The Professional',
    4: 'The Celebrity',
  };

  // ─── Level Follower Ranges ───────────────────────────────
  static const Map<int, String> levelRanges = {
    1: '0 – 1,000',
    2: '1K – 10K',
    3: '10K – 100K',
    4: '100K+',
  };

  // ─── Platform Display Names ──────────────────────────────
  static const Map<String, String> platformNames = {
    'tiktok': 'TikTok',
    'instagram': 'Instagram',
    'youtube': 'YouTube',
    'twitch': 'Twitch',
    'podcast': 'Podcast',
    'linkedin': 'LinkedIn',
    'twitter': 'X (Twitter)',
  };

  // ─── Platform Emoji ───────────────────────────────────────
  static const Map<String, String> platformEmoji = {
    'tiktok': '🎵',
    'instagram': '📸',
    'youtube': '📺',
    'twitch': '🎮',
    'podcast': '🎙️',
    'linkedin': '💼',
    'twitter': '🐦',
  };

  // ─── Niche Display Names ─────────────────────────────────
  static const Map<String, String> nicheNamesEs = {
    'gaming': 'Gaming & Entretenimiento',
    'gastronomy': 'Gastronomía & Lifestyle',
    'fashion': 'Moda & Belleza',
    'finance': 'Finanzas & Emprendimiento',
    'fitness': 'Fitness & Salud',
    'education': 'Educación & Tutoriales',
    'music': 'Música & Arte',
    'travel': 'Viajes & Aventura',
    'technology': 'Tecnología',
    'humor': 'Humor & Comedia',
    'pets': 'Mascotas & Naturaleza',
    'home': 'Hogar & Decoración',
  };

  // ─── Niche Emoji ──────────────────────────────────────────
  static const Map<String, String> nicheEmoji = {
    'gaming': '🎮',
    'gastronomy': '🍳',
    'fashion': '👗',
    'finance': '💰',
    'fitness': '💪',
    'education': '🎓',
    'music': '🎵',
    'travel': '✈️',
    'technology': '🤖',
    'humor': '😂',
    'pets': '🐾',
    'home': '🏠',
  };

  // ─── Storage Keys ─────────────────────────────────────────
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyLanguage = 'app_language';
  static const String keyOnboardingDone = 'onboarding_done';
}
