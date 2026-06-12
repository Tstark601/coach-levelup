import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:levelup_creator/features/auth/presentation/login_page.dart';
import 'package:levelup_creator/features/auth/presentation/register_page.dart';
import 'package:levelup_creator/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:levelup_creator/features/dashboard/presentation/dashboard_page.dart';
import 'package:levelup_creator/features/coach_chat/presentation/coach_chat_page.dart';
import 'package:levelup_creator/features/missions/presentation/missions_page.dart';
import 'package:levelup_creator/shared/providers/auth_provider.dart';

// Route names
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String coachChat = '/coach';
  static const String missions = '/missions';
  static const String profile = '/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }
      if (isAuthenticated && state.matchedLocation == AppRoutes.login) {
        return AppRoutes.dashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        redirect: (_, __) => AppRoutes.login,
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.coachChat,
            name: 'coach',
            builder: (context, state) => const CoachChatPage(),
          ),
          GoRoute(
            path: AppRoutes.missions,
            name: 'missions',
            builder: (context, state) => const MissionsPage(),
          ),
        ],
      ),
    ],
  );
});

/// Main shell with bottom navigation bar
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    int currentIndex = 0;
    if (location.startsWith(AppRoutes.coachChat)) currentIndex = 1;
    if (location.startsWith(AppRoutes.missions)) currentIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF12121A),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF9F67FF),
          unselectedItemColor: const Color(0xFF666680),
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(AppRoutes.dashboard);
              case 1:
                context.go(AppRoutes.coachChat);
              case 2:
                context.go(AppRoutes.missions);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy_rounded),
              label: 'Coach',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rocket_launch_outlined),
              activeIcon: Icon(Icons.rocket_launch_rounded),
              label: 'Misiones',
            ),
          ],
        ),
      ),
    );
  }
}
