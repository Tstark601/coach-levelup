import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:levelup_creator/core/theme/app_colors.dart';
import 'package:levelup_creator/core/router/app_router.dart';
import 'package:levelup_creator/shared/providers/auth_provider.dart';
import 'package:levelup_creator/shared/widgets/gradient_button.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final auth = ref.read(authServiceProvider);
      await auth.signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (mounted) context.go(AppRoutes.onboarding);
    } catch (e) {
      debugPrint('Error de registro: $e');
      setState(() { _error = 'Error: ${e.toString()}'; });
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
                  onPressed: () => context.go(AppRoutes.login),
                ),
                const SizedBox(height: 24),
                Text(
                  'Crea tu cuenta',
                  style: Theme.of(context).textTheme.displaySmall,
                ).animate().fadeIn(),
                const SizedBox(height: 8),
                Text(
                  'Empieza tu camino hacia el éxito como creador',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 40),
                _buildForm(),
              ],
            ),
          ),
        ),
      ),
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
                  Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
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
              helperText: 'Mínimo 8 caracteres',
              helperStyle: const TextStyle(color: AppColors.textMuted),
            ),
            validator: (v) => v == null || v.length < 8 ? 'Mínimo 8 caracteres' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: true,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Confirmar contraseña',
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.textMuted),
            ),
            validator: (v) => v != _passwordCtrl.text ? 'Las contraseñas no coinciden' : null,
          ),
          const SizedBox(height: 32),
          GradientButton(
            label: 'Crear Cuenta Gratis',
            onTap: _loading ? null : _register,
            isLoading: _loading,
          ),
          const SizedBox(height: 20),
          Text(
            'Al registrarte aceptas nuestros Términos de Servicio y Política de Privacidad',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}
