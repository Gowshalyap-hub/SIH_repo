import 'package:flutter/material.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = '${info.version} (${info.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _version = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('about_mastiq') ?? 'About MastiQ'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Image.asset('assets/images/logo.png', height: 80, width: 80),
            ),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context).translate('mastiq') ?? 'MastiQ', style: AppTextStyles.h1),
            const SizedBox(height: 8),
            Text(AppLocalizations.of(context).translate('smart_mastitis_monitoring___he') ?? 'Smart Mastitis Monitoring & Herd Health Platform',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Version $_version',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            ),
            const SizedBox(height: 40),
            
            _buildSection(
              loc.translate('purpose') ?? 'Purpose',
              'MastiQ helps farmers monitor cattle health by combining available sensor readings, milk-related measurements, herd information and AI-assisted current-state risk assessment.',
            ),
            const SizedBox(height: 24),
            
            _buildSection(
              loc.translate('features') ?? 'Features',
              '• Herd management\n• Cow profiles\n• Manual sensor data entry\n• Smart Milk / milk measurements\n• Health monitoring\n• Mastitis risk assessment\n• Alerts\n• Reports & analytics\n• Multi-language support\n• Veterinary contact support',
            ),
            const SizedBox(height: 24),

            _buildSection(
              loc.translate('technology') ?? 'Technology',
              '• Flutter (Mobile App)\n• FastAPI (Backend)\n• SQLite (Database)\n• MQTT/Wokwi (Sensor Integration)\n• AI/ML Current-State Assessment',
            ),
            
            const SizedBox(height: 40),
            Text(AppLocalizations.of(context).translate('__2026_mastiq__all_rights_rese') ?? '© 2026 MastiQ. All rights reserved.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Text(content, style: AppTextStyles.bodyMedium.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
