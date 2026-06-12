import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:levelup_creator/core/theme/app_colors.dart';
import 'package:levelup_creator/core/constants/app_constants.dart';
import 'package:levelup_creator/core/router/app_router.dart';
import 'package:levelup_creator/shared/widgets/gradient_button.dart';
import 'package:levelup_creator/features/onboarding/data/onboarding_service.dart';

// ─── Onboarding State ─────────────────────────────────────────────────────────

class OnboardingState {
  final int currentStep;
  final String username;
  final String platform;
  final String? secondaryPlatform;
  final String niche;
  final String? subNiche;
  final String? targetAudience;
  final String? ageRange;
  final int followersCount;
  final String publishFrequency;
  final String fearType;
  final int weeklyHours;
  final String bestTime;
  final List<String> motivations;
  final String goalDescription;
  final String language;

  const OnboardingState({
    this.currentStep = 0,
    this.username = '',
    this.platform = '',
    this.secondaryPlatform,
    this.niche = '',
    this.subNiche,
    this.targetAudience,
    this.ageRange,
    this.followersCount = 0,
    this.publishFrequency = 'never',
    this.fearType = 'camera',
    this.weeklyHours = 3,
    this.bestTime = 'afternoon',
    this.motivations = const [],
    this.goalDescription = '',
    this.language = 'es',
  });

  OnboardingState copyWith({
    int? currentStep,
    String? username,
    String? platform,
    String? secondaryPlatform,
    String? niche,
    String? subNiche,
    String? targetAudience,
    String? ageRange,
    int? followersCount,
    String? publishFrequency,
    String? fearType,
    int? weeklyHours,
    String? bestTime,
    List<String>? motivations,
    String? goalDescription,
    String? language,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      username: username ?? this.username,
      platform: platform ?? this.platform,
      secondaryPlatform: secondaryPlatform ?? this.secondaryPlatform,
      niche: niche ?? this.niche,
      subNiche: subNiche ?? this.subNiche,
      targetAudience: targetAudience ?? this.targetAudience,
      ageRange: ageRange ?? this.ageRange,
      followersCount: followersCount ?? this.followersCount,
      publishFrequency: publishFrequency ?? this.publishFrequency,
      fearType: fearType ?? this.fearType,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      bestTime: bestTime ?? this.bestTime,
      motivations: motivations ?? this.motivations,
      goalDescription: goalDescription ?? this.goalDescription,
      language: language ?? this.language,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void nextStep() => state = state.copyWith(currentStep: state.currentStep + 1);
  void prevStep() => state = state.copyWith(currentStep: state.currentStep - 1);
  void setUsername(String v) => state = state.copyWith(username: v);
  void setPlatform(String v) => state = state.copyWith(platform: v);
  void setSecondaryPlatform(String? v) => state = state.copyWith(secondaryPlatform: v);
  void setNiche(String v) => state = state.copyWith(niche: v, subNiche: null);
  void setSubNiche(String? v) => state = state.copyWith(subNiche: v);
  void setTargetAudience(String? v) => state = state.copyWith(targetAudience: v);
  void setAgeRange(String? v) => state = state.copyWith(ageRange: v);
  void setFollowers(int v) => state = state.copyWith(followersCount: v);
  void setPublishFrequency(String v) => state = state.copyWith(publishFrequency: v);
  void setFear(String v) => state = state.copyWith(fearType: v);
  void setWeeklyHours(int v) => state = state.copyWith(weeklyHours: v);
  void setBestTime(String v) => state = state.copyWith(bestTime: v);
  void toggleMotivation(String v) {
    final list = List<String>.from(state.motivations);
    if (list.contains(v)) list.remove(v); else list.add(v);
    state = state.copyWith(motivations: list);
  }
  void setGoal(String v) => state = state.copyWith(goalDescription: v);
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);

// ─── Onboarding Page ──────────────────────────────────────────────────────────

class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    const totalSteps = 7;

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
          child: Column(
            children: [
              // Progress Bar
              _buildProgressBar(state.currentStep, totalSteps),
              // Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: child,
                  ),
                  child: _buildStep(context, ref, state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(int step, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          Row(
            children: List.generate(total, (i) => Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: i <= step
                      ? AppColors.primaryGradient
                      : null,
                  color: i > step ? AppColors.border : null,
                ),
              ),
            )),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${step + 1} / $total',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, WidgetRef ref, OnboardingState state) {
    switch (state.currentStep) {
      case 0:
        return _Step1Welcome(key: const ValueKey(0));
      case 1:
        return _Step2Platform(key: const ValueKey(1));
      case 2:
        return _Step3Niche(key: const ValueKey(2));
      case 3:
        return _Step4Audience(key: const ValueKey(3));
      case 4:
        return _Step5StartingPoint(key: const ValueKey(4));
      case 5:
        return _Step6Availability(key: const ValueKey(5));
      case 6:
        return _Step7Motivation(key: const ValueKey(6));
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Step 1: Welcome / Username ───────────────────────────────────────────────

class _Step1Welcome extends ConsumerStatefulWidget {
  const _Step1Welcome({super.key});
  @override
  ConsumerState<_Step1Welcome> createState() => _Step1WelcomeState();
}

class _Step1WelcomeState extends ConsumerState<_Step1Welcome> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl.text = ref.read(onboardingProvider).username;
  }

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      title: '¡Bienvenido! 🎉',
      subtitle: '¿Cómo quieres que te llame tu coach?',
      canContinue: _ctrl.text.trim().length >= 3,
      onNext: () {
        ref.read(onboardingProvider.notifier).setUsername(_ctrl.text.trim());
        ref.read(onboardingProvider.notifier).nextStep();
      },
      child: Column(
        children: [
          TextFormField(
            controller: _ctrl,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: 'Tu nombre de creador...',
              hintStyle: TextStyle(color: AppColors.textMuted),
            ),
            maxLength: 50,
          ),
          const SizedBox(height: 16),
          Text(
            'No tiene que ser tu nombre real. Puede ser tu alias o nombre de usuario en redes.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Platform ─────────────────────────────────────────────────────────

class _Step2Platform extends ConsumerWidget {
  const _Step2Platform({super.key});

  static const _platforms = [
    ('tiktok', '🎵', 'TikTok', 'Videos cortos virales'),
    ('instagram', '📸', 'Instagram', 'Reels, fotos y stories'),
    ('youtube', '📺', 'YouTube', 'Videos largos y Shorts'),
    ('twitch', '🎮', 'Twitch', 'Streams en vivo'),
    ('podcast', '🎙️', 'Podcast', 'Audio y conversaciones'),
    ('linkedin', '💼', 'LinkedIn', 'Contenido profesional'),
    ('twitter', '🐦', 'X (Twitter)', 'Hilos y debate'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return _StepWrapper(
      title: '⭐ Tu plataforma principal',
      subtitle: 'Esta es la clave de todo tu plan. Elige una para empezar.',
      canContinue: state.platform.isNotEmpty,
      onNext: () => notifier.nextStep(),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _platforms.map((p) {
          final (id, emoji, name, desc) = p;
          final selected = state.platform == id;
          return GestureDetector(
            onTap: () => notifier.setPlatform(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: (MediaQuery.of(context).size.width - 60) / 2,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.primaryGradient : null,
                color: selected ? null : AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? Colors.transparent : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: selected ? [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12),
                ] : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 3: Niche ────────────────────────────────────────────────────────────

class _Step3Niche extends ConsumerWidget {
  const _Step3Niche({super.key});

  static const _niches = [
    ('gaming', '🎮', 'Gaming'),
    ('gastronomy', '🍳', 'Gastronomía'),
    ('fashion', '👗', 'Moda & Belleza'),
    ('finance', '💰', 'Finanzas'),
    ('fitness', '💪', 'Fitness'),
    ('education', '🎓', 'Educación'),
    ('music', '🎵', 'Música & Arte'),
    ('travel', '✈️', 'Viajes'),
    ('technology', '🤖', 'Tecnología'),
    ('humor', '😂', 'Humor'),
    ('pets', '🐾', 'Mascotas'),
    ('home', '🏠', 'Hogar'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return _StepWrapper(
      title: '⭐ Tu nicho de contenido',
      subtitle: 'Cuanto más específico, más rápido creces.',
      canContinue: state.niche.isNotEmpty,
      onNext: () => notifier.nextStep(),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _niches.map((n) {
          final (id, emoji, name) = n;
          final selected = state.niche == id;
          return GestureDetector(
            onTap: () => notifier.setNiche(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.primaryGradient : null,
                color: selected ? null : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? Colors.transparent : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 4: Audience ─────────────────────────────────────────────────────────

class _Step4Audience extends ConsumerStatefulWidget {
  const _Step4Audience({super.key});
  @override
  ConsumerState<_Step4Audience> createState() => _Step4AudienceState();
}

class _Step4AudienceState extends ConsumerState<_Step4Audience> {
  final _audienceCtrl = TextEditingController();

  static const _ageRanges = [
    ('under_18', 'Sub 18', 'Gen Z y más jóvenes'),
    ('18_24', '18-24', 'Jóvenes adultos'),
    ('25_34', '25-34', 'Millennials'),
    ('35_plus', '35+', 'Profesionales / Adultos'),
    ('all', 'Todos', 'Para todas las edades'),
  ];

  @override
  void initState() {
    super.initState();
    _audienceCtrl.text = ref.read(onboardingProvider).targetAudience ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return _StepWrapper(
      title: '🎯 Tu público objetivo',
      subtitle: '¿A quién le hablas en tus videos?',
      canContinue: state.ageRange != null && state.ageRange!.isNotEmpty && _audienceCtrl.text.trim().isNotEmpty,
      onNext: () {
        notifier.setTargetAudience(_audienceCtrl.text.trim());
        notifier.nextStep();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('¿Cómo describirías a tus seguidores ideales?'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _audienceCtrl,
            onChanged: (_) => setState(() {}),
            maxLength: 100,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ej: Emprendedores, estudiantes universitarios...',
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 28),
          const _SectionLabel('¿Qué rango de edad predomina?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ageRanges.map((o) {
              final (id, label, desc) = o;
              final selected = state.ageRange == id;
              return GestureDetector(
                onTap: () => notifier.setAgeRange(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    color: selected ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? Colors.transparent : AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(label, style: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
                      Text(desc, style: TextStyle(
                        color: selected ? Colors.white70 : AppColors.textMuted,
                        fontSize: 10,
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Step 5: Starting Point ───────────────────────────────────────────────────

class _Step5StartingPoint extends ConsumerWidget {
  const _Step5StartingPoint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    const followerOptions = [
      (0, '0', 'Aún no he empezado'),
      (250, '1–500', 'Apenas comenzando'),
      (750, '500–1K', 'Tengo algo de audiencia'),
      (5000, '1K–10K', 'Micro-influencer'),
      (50000, '10K+', 'Ya tengo audiencia'),
    ];

    const fearOptions = [
      ('camera', '📷', 'La cámara me da miedo'),
      ('editing', '✂️', 'No sé editar'),
      ('ideas', '💡', 'No sé qué decir'),
      ('consistency', '📅', 'No soy constante'),
      ('everything', '😅', 'Todo lo anterior'),
    ];

    return _StepWrapper(
      title: '¿Dónde estás hoy?',
      subtitle: 'Sé honesto — esto nos ayuda a personalizar tu plan.',
      canContinue: true,
      onNext: () => notifier.nextStep(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel('¿Cuántos seguidores tienes en ${AppConstants.platformNames[state.platform] ?? "tu plataforma"}?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: followerOptions.map((o) {
              final (count, label, desc) = o;
              final selected = state.followersCount == count;
              return GestureDetector(
                onTap: () => notifier.setFollowers(count),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    color: selected ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? Colors.transparent : AppColors.border),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          const _SectionLabel('¿Cuál es tu mayor obstáculo?'),
          const SizedBox(height: 12),
          ...fearOptions.map((o) {
            final (id, emoji, label) = o;
            final selected = state.fearType == id;
            return GestureDetector(
              onTap: () => notifier.setFear(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.primaryGradient : null,
                  color: selected ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? Colors.transparent : AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Step 6: Availability ─────────────────────────────────────────────────────

class _Step6Availability extends ConsumerWidget {
  const _Step6Availability({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    const hourOptions = [
      (1, '< 1h', 'Muy poco tiempo'),
      (2, '1–3h', 'Tiempo limitado'),
      (5, '3–7h', 'Tiempo moderado'),
      (10, '7–14h', 'Bastante tiempo'),
      (20, '14h+', 'Tiempo completo'),
    ];

    const timeOptions = [
      ('early_morning', '🌅', 'Madrugada / Mañana'),
      ('midday', '☀️', 'Mediodía'),
      ('afternoon', '🌤️', 'Tarde'),
      ('night', '🌙', 'Noche'),
      ('variable', '🔄', 'Varía cada día'),
    ];

    return _StepWrapper(
      title: '⏰ Tu tiempo disponible',
      subtitle: 'Diseñaremos un plan realista según tu agenda.',
      canContinue: true,
      onNext: () => notifier.nextStep(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('¿Cuántas horas a la semana puedes crear contenido?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: hourOptions.map((o) {
              final (hours, label, desc) = o;
              final selected = state.weeklyHours == hours;
              return GestureDetector(
                onTap: () => notifier.setWeeklyHours(hours),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    color: selected ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? Colors.transparent : AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Text(label, style: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      )),
                      Text(desc, style: TextStyle(
                        color: selected ? Colors.white70 : AppColors.textMuted,
                        fontSize: 10,
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          const _SectionLabel('¿Cuándo sueles tener más energía para crear?'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: timeOptions.map((o) {
              final (id, emoji, label) = o;
              final selected = state.bestTime == id;
              return GestureDetector(
                onTap: () => notifier.setBestTime(id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    color: selected ? null : AppColors.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? Colors.transparent : AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(label, style: TextStyle(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Step 7: Motivation ───────────────────────────────────────────────────────

class _Step7Motivation extends ConsumerStatefulWidget {
  const _Step7Motivation({super.key});
  @override
  ConsumerState<_Step7Motivation> createState() => _Step7MotivationState();
}

class _Step7MotivationState extends ConsumerState<_Step7Motivation> {
  final _goalCtrl = TextEditingController();
  bool _loading = false;

  static const _motivations = [
    ('fame', '🌟', 'Fama y reconocimiento'),
    ('income', '💰', 'Ingresos y monetización'),
    ('impact', '💡', 'Generar impacto'),
    ('community', '🤝', 'Construir comunidad'),
    ('learning', '📚', 'Aprender y crecer'),
  ];

  Future<void> _submit() async {
    final state = ref.read(onboardingProvider);
    if (state.motivations.isEmpty || _goalCtrl.text.trim().isEmpty) return;

    ref.read(onboardingProvider.notifier).setGoal(_goalCtrl.text.trim());
    setState(() => _loading = true);

    try {
      final service = ref.read(onboardingServiceProvider);
      await service.submitOnboarding(state.copyWith(goalDescription: _goalCtrl.text.trim()));
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final canSubmit = state.motivations.isNotEmpty && _goalCtrl.text.trim().length >= 10;

    return _StepWrapper(
      title: '🚀 Tu motivación',
      subtitle: 'Esto ayudará al coach a mantenerte enfocado en tus razones.',
      canContinue: canSubmit,
      onNext: _loading ? null : _submit,
      nextLabel: _loading ? 'Generando tu plan...' : '¡Iniciar mi viaje!',
      isLastStep: true,
      isLoading: _loading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('¿Qué te impulsa a ser creador? (puedes elegir varios)'),
          const SizedBox(height: 12),
          ..._motivations.map((m) {
            final (id, emoji, label) = m;
            final selected = state.motivations.contains(id);
            return GestureDetector(
              onTap: () => notifier.toggleMotivation(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: selected ? AppColors.primaryGradient : null,
                  color: selected ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selected ? Colors.transparent : AppColors.border),
                ),
                child: Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(label, style: TextStyle(
                      color: selected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    )),
                    const Spacer(),
                    if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          const _SectionLabel('¿Cuál es tu meta en los próximos 6 meses?'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _goalCtrl,
            onChanged: (_) => setState(() {}),
            maxLines: 3,
            maxLength: 150,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ej: Llegar a 1000 seguidores y publicar 3 veces por semana en TikTok...',
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Step Wrapper ──────────────────────────────────────────────────────

class _StepWrapper extends ConsumerWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final bool canContinue;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool isLastStep;
  final bool isLoading;

  const _StepWrapper({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.canContinue,
    required this.onNext,
    this.nextLabel = 'Continuar',
    this.isLastStep = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineLarge)
                    .animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 8),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium)
                    .animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 32),
                child.animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Bottom navigation buttons
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Row(
            children: [
              if (state.currentStep > 0)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => ref.read(onboardingProvider.notifier).prevStep(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 18),
                  ),
                ),
              if (state.currentStep > 0) const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: GradientButton(
                  label: nextLabel,
                  onTap: canContinue ? onNext : null,
                  isLoading: isLoading,
                  icon: isLastStep ? Icons.rocket_launch_rounded : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
    );
  }
}
