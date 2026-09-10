import 'package:flutter/material.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('register')), backgroundColor: AppColors.surface, elevation: 0, foregroundColor: AppColors.textPrimary),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(label: AppLocalizations.of(context).translate('full_name') ?? 'Full Name'),
            const SizedBox(height: 16),
            AppTextField(label: AppLocalizations.of(context).translate('email') ?? 'Email'),
            const SizedBox(height: 16),
            AppTextField(label: AppLocalizations.of(context).translate('password') ?? 'Password', obscureText: true),
            const SizedBox(height: 32),
            AppButton(text: AppLocalizations.of(context).translate('register'),
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
