import 'package:flutter/material.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('help_support') ?? 'Help & Support'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildExpansionTile(
            loc.translate('getting_started') ?? 'Getting Started',
            [
              _buildFaqItem('How to add a cow?', 'Navigate to the Herd screen and tap the "+" button or "Add Cow" to enter cow details.'),
              _buildFaqItem('How to record sensor/manual readings?', 'Go to the Manual Data or Smart Milk screen, enter the values such as EC and pH, and save the reading.'),
              _buildFaqItem('How to view cow health?', 'Tap on any cow in the Herd list to view its complete health profile, history, and AI risk prediction.'),
              _buildFaqItem('How to understand risk levels?', 'The AI risk level indicates the current probability of mastitis based on recent sensor data.'),
            ],
          ),
          const SizedBox(height: 12),
          _buildExpansionTile(
            loc.translate('using_mastiq') ?? 'Using MastiQ',
            [
              _buildFaqItem('Dashboard', 'Provides a high-level overview of your herd\'s health and active alerts.'),
              _buildFaqItem('Herd Management', 'View and manage all cows in your farm.'),
              _buildFaqItem('Alerts', 'Shows high and moderate risk cows that require immediate attention.'),
              _buildFaqItem('Reports', 'View risk distribution and milk production trends for your farm.'),
            ],
          ),
          const SizedBox(height: 12),
          _buildExpansionTile(
            loc.translate('risk_levels_explained') ?? 'Risk Levels Explained',
            [
              _buildFaqItem('Healthy', 'Cow is healthy with normal milk parameters.'),
              _buildFaqItem('Moderate / At Risk', 'Cow shows early signs or slight deviations. Monitor closely.'),
              _buildFaqItem('High / Critical', 'Cow has a high probability of mastitis. Contact veterinarian immediately.'),
            ],
          ),
          const SizedBox(height: 12),
          _buildExpansionTile(
            loc.translate('faq') ?? 'Frequently Asked Questions',
            [
              _buildFaqItem('How do I update cow information?', 'Go to the Cow Profile and select the edit option.'),
              _buildFaqItem('What should I do when a high-risk alert appears?', 'Inspect the cow and contact your veterinarian using the Farm Profile contact button.'),
              _buildFaqItem('How do I change the language?', 'Go to Settings > App Language and select your preferred language.'),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.support_agent, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(loc.translate('contact_support') ?? 'Contact Support', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  loc.translate('support_not_configured') ?? 'Support contact not configured',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildExpansionTile(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(title, style: AppTextStyles.bodyLarge),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: children,
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(answer, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
