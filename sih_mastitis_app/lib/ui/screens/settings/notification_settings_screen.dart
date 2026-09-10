import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/app_localizations.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _mastitisRiskAlerts = true;
  bool _highRiskAlerts = true;
  bool _moderateRiskAlerts = true;
  bool _sensorAlerts = true;
  bool _generalNotifications = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mastitisRiskAlerts = prefs.getBool('notif_mastitis_risk') ?? true;
      _highRiskAlerts = prefs.getBool('notif_high_risk') ?? true;
      _moderateRiskAlerts = prefs.getBool('notif_moderate_risk') ?? true;
      _sensorAlerts = prefs.getBool('notif_sensor') ?? true;
      _generalNotifications = prefs.getBool('notif_general') ?? true;
      _isLoading = false;
    });
  }

  Future<void> _updateSetting(String key, bool value, Function(bool) updater) async {
    updater(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.translate('notification_settings') ?? 'Notification Settings'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle(loc.translate('risk_alerts') ?? 'Risk Alerts'),
                _buildSwitchTile(
                  loc.translate('mastitis_risk_alerts') ?? 'Mastitis Risk Alerts',
                  'Receive alerts when risk increases',
                  _mastitisRiskAlerts,
                  (val) => _updateSetting('notif_mastitis_risk', val, (v) => setState(() => _mastitisRiskAlerts = v)),
                ),
                _buildSwitchTile(
                  loc.translate('high_risk_alerts') ?? 'High Risk Alerts',
                  'Immediate alerts for critical cows',
                  _highRiskAlerts,
                  (val) => _updateSetting('notif_high_risk', val, (v) => setState(() => _highRiskAlerts = v)),
                ),
                _buildSwitchTile(
                  loc.translate('moderate_risk_alerts') ?? 'Moderate Risk Alerts',
                  'Warnings for at-risk cows',
                  _moderateRiskAlerts,
                  (val) => _updateSetting('notif_moderate_risk', val, (v) => setState(() => _moderateRiskAlerts = v)),
                ),
                
                const SizedBox(height: 24),
                _buildSectionTitle(loc.translate('system_alerts') ?? 'System Alerts'),
                _buildSwitchTile(
                  loc.translate('sensor_reading_alerts') ?? 'Sensor/Reading Alerts',
                  'Notifications for new smart milk data',
                  _sensorAlerts,
                  (val) => _updateSetting('notif_sensor', val, (v) => setState(() => _sensorAlerts = v)),
                ),
                _buildSwitchTile(
                  loc.translate('general_notifications') ?? 'General Notifications',
                  'App updates and general messages',
                  _generalNotifications,
                  (val) => _updateSetting('notif_general', val, (v) => setState(() => _generalNotifications = v)),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.h3),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(title, style: AppTextStyles.bodyLarge),
        subtitle: Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
