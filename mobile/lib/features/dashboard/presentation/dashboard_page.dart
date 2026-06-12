import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:levelup_creator/core/theme/app_colors.dart';
import 'package:levelup_creator/core/constants/app_constants.dart';
import 'package:levelup_creator/core/router/app_router.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D1A), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildLevelCard(context, ref),
                const SizedBox(height: 20),
                _buildXPProgress(context),
                const SizedBox(height: 24),
                _buildTodaysMissions(context),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buenos días 👋',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                'Creator',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
        ),
        // Streak badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 4),
              Text(
                '0 días',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildLevelCard(BuildContext context, WidgetRef ref) {
    const level = 1;
    return GestureDetector(
      onTap: () => _showFollowersModal(context, ref),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.getLevelGradient(level),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.getLevelColor(level).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🥉', style: TextStyle(fontSize: 48)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NIVEL 1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    AppConstants.levelNamesEs[level]!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Seguidores: 0–1,000',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1);
  }

  Widget _buildXPProgress(BuildContext context) {
    const currentXP = 0;
    const targetXP = 500;
    final progress = currentXP / targetXP;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Experiencia (XP)', style: Theme.of(context).textTheme.titleMedium),
              Text(
                '$currentXP / $targetXP XP',
                style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${targetXP - currentXP} XP para subir al Nivel 2',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildTodaysMissions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Misiones de hoy 🎯', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        _MissionCard(
          emoji: '📱',
          title: 'Primera publicación',
          description: 'Crea y publica tu primer contenido en tu plataforma',
          xp: 100,
          difficulty: 'Fácil',
        ),
        const SizedBox(height: 10),
        _MissionCard(
          emoji: '✍️',
          title: 'Define tu nicho',
          description: 'Escribe en 1 frase qué tipo de contenido harás',
          xp: 50,
          difficulty: 'Fácil',
        ),
        const SizedBox(height: 10),
        _MissionCard(
          emoji: '🎯',
          title: 'Optimiza tu bio',
          description: 'Con ayuda del Coach, mejora tu descripción de perfil',
          xp: 75,
          difficulty: 'Media',
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acciones rápidas ⚡', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _QuickActionCard(
              emoji: '🤖',
              label: 'Hablar con Coach',
              color: AppColors.primary,
              onTap: () => context.go(AppRoutes.coachChat),
            )),
            const SizedBox(width: 12),
            Expanded(child: _QuickActionCard(
              emoji: '✍️',
              label: 'Generar Guión',
              color: AppColors.secondary,
              onTap: () => _showGenerateModal(context, 'script'),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _QuickActionCard(
              emoji: '💡',
              label: 'Ideas de Contenido',
              color: AppColors.warning,
              onTap: () => _showGenerateModal(context, 'ideas'),
            )),
            const SizedBox(width: 12),
            Expanded(child: _QuickActionCard(
              emoji: '📊',
              label: 'Ver Tendencias',
              color: AppColors.success,
              onTap: () {},
            )),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  void _showFollowersModal(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Actualizar Seguidores', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Número actual de seguidores...',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement API call to PATCH /users/me/followers
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Seguidores actualizados (Mock)')),
              );
            },
            child: const Text('Actualizar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showGenerateModal(BuildContext context, String type) {
    final ctrl = TextEditingController();
    final title = type == 'script' ? 'Generar Guión' : 'Ideas de Contenido';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '¿De qué trata tu contenido?',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement API call to /coach/content/script or ideas
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Generando $type (Mock)...')),
              );
            },
            child: const Text('Generar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final int xp;
  final String difficulty;

  const _MissionCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.xp,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(description, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+$xp XP',
                  style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.check_circle_outline, color: AppColors.textMuted, size: 22),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
