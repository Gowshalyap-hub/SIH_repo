import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../providers/localization_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locProvider = context.watch<LocalizationProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    String currentLanguageName = 'English';
    if (locProvider.locale.languageCode == 'ta') currentLanguageName = 'Tamil';
    if (locProvider.locale.languageCode == 'hi') currentLanguageName = 'Hindi';
    if (locProvider.locale.languageCode == 'ml') currentLanguageName = 'Malayalam';
    if (locProvider.locale.languageCode == 'te') currentLanguageName = 'Telugu';
    if (locProvider.locale.languageCode == 'kn') currentLanguageName = 'Kannada';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings')),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Header
            GestureDetector(
              onTap: () => context.push('/account-settings'),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.person, size: 40, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(user?.name ?? user?.email ?? 'Authorized User', style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text(user?.role ?? '', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Settings List
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  _SettingsTile(icon: Icons.store, title: AppLocalizations.of(context).translate('farm_profile') ?? 'Farm Profile', onTap: () => context.push('/farm-profile')),
                  _SettingsTile(icon: Icons.person_outline, title: AppLocalizations.of(context).translate('account_settings') ?? 'Account Settings', onTap: () => context.push('/account-settings')),
                  _SettingsTile(icon: Icons.notifications_none, title: AppLocalizations.of(context).translate('notification_settings') ?? 'Notification Settings', onTap: () => context.push('/notification-settings')),
                  _SettingsTile(
                    icon: Icons.language, 
                    title: AppLocalizations.of(context).translate('app_language') ?? 'App Language', 
                    trailing: Text('$currentLanguageName >', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                    onTap: () => _showLanguageDialog(context, locProvider),
                  ),
                  _SettingsTile(icon: Icons.help_outline, title: AppLocalizations.of(context).translate('help_support') ?? 'Help & Support', onTap: () => context.push('/help-support')),
                  _SettingsTile(icon: Icons.info_outline, title: AppLocalizations.of(context).translate('about_mastiq') ?? 'About MastiQ', onTap: () => context.push('/about')),
                  _SettingsTile(
                    icon: Icons.logout, 
                    title: AppLocalizations.of(context).translate('logout'), 
                    iconColor: AppColors.riskHigh, 
                    textColor: AppColors.riskHigh,
                    showArrow: false,
                    onTap: () => _showLogoutConfirmDialog(context, authProvider),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthProvider provider) {
    final nameController = TextEditingController(text: provider.currentUser?.name ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('edit_profile')),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  provider.updateProfile(nameController.text.trim());
                }
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).translate('save')),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmDialog(BuildContext context, AuthProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('logout')),
          content: Text(AppLocalizations.of(context).translate('are_you_sure_you_want_to_log_out_')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await provider.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskHigh),
              child: Text(AppLocalizations.of(context).translate('logout')),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context, LocalizationProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context).translate('english')),
                trailing: provider.locale.languageCode == 'en' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () { provider.setLanguage('en'); Navigator.pop(context); },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).translate('tamil________')),
                trailing: provider.locale.languageCode == 'ta' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () { provider.setLanguage('ta'); Navigator.pop(context); },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).translate('hindi_________')),
                trailing: provider.locale.languageCode == 'hi' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () { provider.setLanguage('hi'); Navigator.pop(context); },
              ),
              ListTile(
                title: const Text('Malayalam (മലയാളം)'),
                trailing: provider.locale.languageCode == 'ml' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () { provider.setLanguage('ml'); Navigator.pop(context); },
              ),
              ListTile(
                title: const Text('Telugu (తెలుగు)'),
                trailing: provider.locale.languageCode == 'te' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () { provider.setLanguage('te'); Navigator.pop(context); },
              ),
              ListTile(
                title: const Text('Kannada (ಕನ್ನಡ)'),
                trailing: provider.locale.languageCode == 'kn' ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () { provider.setLanguage('kn'); Navigator.pop(context); },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon, 
    required this.title, 
    this.trailing,
    this.iconColor = AppColors.textPrimary,
    this.textColor = AppColors.textPrimary,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: AppTextStyles.bodyMedium.copyWith(color: textColor)),
      trailing: trailing ?? (showArrow ? const Icon(Icons.chevron_right, color: AppColors.textHint) : null),
      onTap: onTap,
    );
  }
}
