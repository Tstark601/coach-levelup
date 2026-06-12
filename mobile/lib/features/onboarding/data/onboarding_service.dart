import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:levelup_creator/core/constants/app_constants.dart';
import 'package:levelup_creator/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  return OnboardingService();
});

class OnboardingService {
  final _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<Map<String, dynamic>> submitOnboarding(OnboardingState state) async {
    // Get current auth token from Supabase
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception('No authentication session found');

    final token = session.accessToken;

    final response = await _dio.post(
      '/onboarding/complete',
      data: {
        'username': state.username,
        'platform': state.platform,
        'secondary_platform': state.secondaryPlatform,
        'niche': state.niche,
        'sub_niche': state.subNiche,
        'target_audience': state.targetAudience,
        'age_range': state.ageRange,
        'followers_count': state.followersCount,
        'publish_frequency': state.publishFrequency,
        'fear_type': state.fearType,
        'weekly_hours': state.weeklyHours,
        'best_time': state.bestTime,
        'motivations': state.motivations,
        'goal_description': state.goalDescription,
        'language': state.language,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data as Map<String, dynamic>;
  }
}
