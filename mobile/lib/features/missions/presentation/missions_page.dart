import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:levelup_creator/core/theme/app_colors.dart';
import 'package:levelup_creator/core/constants/app_constants.dart';

class MissionsPage extends ConsumerStatefulWidget {
  const MissionsPage({super.key});

  @override
  ConsumerState<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends ConsumerState<MissionsPage> {
  bool _loading = true;
  List<dynamic> _missions = [];

  final _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) return;

      final response = await _dio.get(
        '/missions/',
        options: Options(headers: {'Authorization': 'Bearer ${session.accessToken}'}),
      );

      if (mounted) {
        setState(() {
          _missions = response.data['missions'] ?? [];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _completeMission(String id) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      await _dio.post(
        '/missions/$id/complete',
        options: Options(headers: {'Authorization': 'Bearer ${session?.accessToken}'}),
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Misión completada! +XP')));
      _loadMissions(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al completar la misión.')));
    }
  }

  Future<void> _actionMission(String id, String action) async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      await _dio.post(
        '/missions/$id/$action',
        options: Options(headers: {'Authorization': 'Bearer ${session?.accessToken}'}),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action == 'rollover' ? 'Misión pospuesta.' : 'Misión reemplazada.')),
      );
      _loadMissions(); // Refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al procesar la acción.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Misiones')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _missions.isEmpty
              ? const Center(child: Text('No hay misiones activas.', style: TextStyle(color: AppColors.textMuted)))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _SectionHeader('Hoy 🎯'),
                    const SizedBox(height: 12),
                    ..._missions.map((m) {
                      final title = m['title'] ?? 'Misión';
                      final xp = m['xp_reward'] ?? 50;
                      final diff = m['difficulty'] ?? 'Media';
                      final isCompleted = m['status'] == 'completed';
                      final id = m['id'];

                      return _MissionTile(
                        id: id,
                        emoji: '📱', // Mock emoji
                        title: title,
                        xp: xp,
                        isCompleted: isCompleted,
                        difficulty: diff,
                        onComplete: () => _completeMission(id),
                        onAction: (action) => _actionMission(id, action),
                      );
                    }),
                  ],
                ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }
}

class _MissionTile extends StatelessWidget {
  final String id;
  final String emoji;
  final String title;
  final int xp;
  final bool isCompleted;
  final String difficulty;
  final bool isWeekly;
  final VoidCallback onComplete;
  final Function(String) onAction;

  const _MissionTile({
    required this.id,
    required this.emoji,
    required this.title,
    required this.xp,
    required this.isCompleted,
    required this.difficulty,
    this.isWeekly = false,
    required this.onComplete,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.success.withOpacity(0.08) : AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted ? AppColors.success.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_rounded, color: AppColors.success, size: 22)
                  : Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? AppColors.textMuted : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        difficulty,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                      ),
                    ),
                    if (isWeekly) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Semanal',
                          style: TextStyle(color: AppColors.secondary, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isCompleted)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
                  color: AppColors.surface,
                  onSelected: onAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'complete',
                      child: Text('Completar', style: TextStyle(color: AppColors.success)),
                    ),
                    const PopupMenuItem(
                      value: 'rollover',
                      child: Text('Posponer', style: TextStyle(color: AppColors.textPrimary)),
                    ),
                    const PopupMenuItem(
                      value: 'replace',
                      child: Text('Reemplazar (Imposible)', style: TextStyle(color: AppColors.warning)),
                    ),
                  ],
                ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$xp XP',
                    style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
