import 'package:flutter/material.dart';
import '../../../core/utils/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Loading state handled by AuthProvider

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    // TODO: PROTOTYPE-ONLY authentication. Remove before production.
    // if (email.isEmpty || password.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(AppLocalizations.of(context).translate('please_enter_email_and_password'))),
    //   );
    //   return;
    // }
    try {
      print("LOGIN BUTTON PRESSED");
      print("LOGIN EMAIL FROM CONTROLLER: ${_emailController.text}");
      await authProvider.login(email, password);
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      final msg = authProvider.error ??
          (e.toString().contains('TimeoutException')
              ? 'Unable to connect to server. Please check the network.'
              : 'Login failed. Please check your credentials.');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('login')), backgroundColor: AppColors.surface, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset('assets/images/logo.png', width: 80, height: 80),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).translate('mastiq') ?? 'MastiQ', style: AppTextStyles.h1.copyWith(color: AppColors.primary, fontSize: 28), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(AppLocalizations.of(context).translate('early_warning_system') ?? 'Early Warning System', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Text(AppLocalizations.of(context).translate('welcome_back') ?? 'Welcome Back', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context).translate('glad_to_see_you_again_') ?? 'Glad to see you again!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              AppTextField(label: AppLocalizations.of(context).translate('email') ?? 'Email', controller: _emailController),
              const SizedBox(height: 16),
              AppTextField(label: AppLocalizations.of(context).translate('password') ?? 'Password', obscureText: true, controller: _passwordController),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context).translate('forgot_password_') ?? 'Forgot Password?', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
                ),
              ),
              const SizedBox(height: 16),
                authProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(text: AppLocalizations.of(context).translate('login'),
                      onPressed: () => _handleLogin(context),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.push('/register'),
                child: Text(AppLocalizations.of(context).translate('don_') ?? 'Don\'t have an account? Register'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
