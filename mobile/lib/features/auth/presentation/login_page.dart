import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:levelup_creator/core/theme/app_colors.dart';
import 'package:levelup_creator/core/router/app_router.dart';
import 'package:levelup_creator/shared/providers/auth_provider.dart';
import 'package:levelup_creator/shared/widgets/gradient_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final auth = ref.read(authServiceProvider);
      await auth.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) context.go(AppRoutes.dashboard);
    } catch (e) {
      debugPrint('Error de inicio de sesión: $e');
      setState(() { _error = 'Error: ${e.toString()}'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      final auth = ref.read(authServiceProvider);
      await auth.signInWithGoogle();
    } catch (e) {
      setState(() { _error = 'Error al iniciar sesión con Google'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo & Title
                _buildHeader(),
                const SizedBox(height: 48),
                // Form
                _buildForm(),
                const SizedBox(height: 24),
                // Google button
                _buildGoogleButton(),
                const SizedBox(height: 32),
                // Register link
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 40),
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Text(
          'LevelUp Creator',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.secondary],
              ).createShader(const Rect.fromLTWH(0, 0, 220, 50)),
          ),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text(
          'Tu coach de IA para crecer como influencer',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted),
            ),
            validator: (v) => v == null || !v.contains('@') ? 'Email inválido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.textMuted,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Iniciar Sesión',
            onTap: _loading ? null : _signIn,
            isLoading: _loading,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _signInWithGoogle,
      icon: const Text('G', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      label: const Text('Continuar con Google'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: AppColors.textPrimary,
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('¿No tienes cuenta? ', style: Theme.of(context).textTheme.bodyMedium),
        TextButton(
          onPressed: () => context.go(AppRoutes.register),
          child: const Text('Regístrate gratis'),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}
