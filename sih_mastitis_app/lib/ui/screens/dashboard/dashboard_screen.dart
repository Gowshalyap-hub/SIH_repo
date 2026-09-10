import 'package:flutter/material.dart';
import '../../../core/utils/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../widgets/app_card.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/herd_provider.dart';
import '../../../providers/alert_provider.dart';
import '../../../models/risk_level.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/localization_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final auth = context.read<AuthProvider>();
      final farmId = auth.currentUser?.farmId ?? 'FARM001';
      context.read<FarmProvider>().loadFarm(farmId);
      context.read<HerdProvider>().loadHerd(farmId);
      context.read<AlertProvider>().loadAlerts(farmId);
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalizationProvider>();
    final farmProvider = context.watch<FarmProvider>();
    final herdProvider = context.watch<HerdProvider>();
    final alertProvider = context.watch<AlertProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(context, authProvider),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final farmId = authProvider.currentUser?.farmId ?? 'FARM001';
            await context.read<FarmProvider>().loadFarm(farmId);
            await context.read<HerdProvider>().loadHerd(farmId);
            await context.read<AlertProvider>().loadAlerts(farmId);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context, authProvider),
                const SizedBox(height: 24),
                _buildHerdHealthCard(herdProvider),
                const SizedBox(height: 24),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildTodayAtAGlance(herdProvider),
                const SizedBox(height: 24),
                _buildRecentAlerts(alertProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.currentUser;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(user?.name ?? 'Farmer'),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(AppLocalizations.of(context).translate('settings')),
            onTap: () {
              Navigator.pop(context); // close drawer
              context.push('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.riskHigh),
            title: Text(AppLocalizations.of(context).translate('logout') ?? 'Logout', style: TextStyle(color: AppColors.riskHigh)),
            onTap: () {
              Navigator.pop(context); // close drawer
              authProvider.logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.textPrimary, size: 28),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).translate('good_morning_') ?? 'Good morning,', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(authProvider.currentUser?.name ?? 'Farmer', style: AppTextStyles.h1.copyWith(fontSize: 24)),
                    Text(AppLocalizations.of(context).translate('___') ?? ' 👋', style: TextStyle(fontSize: 24)),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
              onPressed: () => context.push('/alerts'),
            ),
            GestureDetector(
              onTap: () => context.push('/settings'),
              child: const CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHerdHealthCard(HerdProvider herdProvider) {
    if (herdProvider.isLoading) {
      return const AppCard(child: Center(child: CircularProgressIndicator()));
    }
    
    final total = herdProvider.allCows.length;
    final atRisk = herdProvider.allCows.where((c) => c.currentRiskLevel == RiskLevel.moderate || c.currentRiskLevel == RiskLevel.high).length;
    double healthPercentage = total == 0 ? 100 : ((total - atRisk) / total) * 100;

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).translate('herd_health') ?? 'Herd Health', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('${healthPercentage.toStringAsFixed(0)}%', style: AppTextStyles.h1.copyWith(fontSize: 36, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text(AppLocalizations.of(context).translate('moderate_risk') ?? 'Moderate Risk', style: AppTextStyles.bodySmall.copyWith(color: AppColors.riskModerate)),
                const SizedBox(height: 12),
                SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    value: healthPercentage / 100,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
              // Placeholder for Cow Image
              Opacity(
                opacity: 0.3,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
              ),
            ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionItem(icon: Icons.online_prediction, label: AppLocalizations.of(context).translate('live_data') ?? 'Live Data', onTap: () => context.push('/live-prediction')),
        _ActionItem(icon: Icons.science, label: AppLocalizations.of(context).translate('manual_test') ?? 'Manual Test', onTap: () => context.push('/smart-milk/rfid')),
        _ActionItem(icon: Icons.notifications_none, label: AppLocalizations.of(context).translate('alerts') ?? 'Alerts', onTap: () => context.push('/alerts')),
        _ActionItem(icon: Icons.bar_chart, label: AppLocalizations.of(context).translate('reports') ?? 'Reports', onTap: () => context.push('/analytics')),
      ],
    );
  }

  Widget _buildTodayAtAGlance(HerdProvider herdProvider) {
    final cows = herdProvider.allCows;
    final total = cows.length;
    final atRisk = cows.where((c) => c.currentRiskLevel == RiskLevel.moderate || c.currentRiskLevel == RiskLevel.high).length;
    final milked = cows.where((c) => c.lastMilkYield != null && c.lastMilkYield! > 0).length;
    final labTests = cows.fold<int>(0, (sum, c) => sum + c.manualReadings.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).translate('today_at_a_glance') ?? 'Today at a Glance', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _GlanceCard(title: AppLocalizations.of(context).translate('total_cows') ?? 'Total\nCows', value: total.toString())),
            const SizedBox(width: 12),
            Expanded(child: _GlanceCard(title: AppLocalizations.of(context).translate('at_risk') ?? 'At\nRisk', value: atRisk.toString(), isHighlight: true)),
            const SizedBox(width: 12),
            Expanded(child: _GlanceCard(title: AppLocalizations.of(context).translate('milked') ?? 'Milked', value: milked.toString())),
            const SizedBox(width: 12),
            Expanded(child: _GlanceCard(title: AppLocalizations.of(context).translate('lab_tests') ?? 'Lab\nTests', value: labTests.toString())),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentAlerts(AlertProvider alertProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).translate('recent_alerts') ?? 'Recent Alerts', style: AppTextStyles.h3),
            TextButton(
              onPressed: () => context.push('/alerts'),
              child: Text(AppLocalizations.of(context).translate('view_all') ?? 'View All', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (alertProvider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (alertProvider.error != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context).translate('unable_to_load_alerts') ?? 'Unable to load alerts'),
                TextButton(
                  onPressed: () {
                    final farmId = context.read<AuthProvider>().currentUser?.farmId ?? 'FARM001';
                    context.read<AlertProvider>().loadAlerts(farmId);
                  },
                  child: Text(AppLocalizations.of(context).translate('retry') ?? 'Retry'),
                ),
              ],
            ),
          )
        else if (alertProvider.alerts.isEmpty)
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(AppLocalizations.of(context).translate('no_recent_alerts_') ?? 'No recent alerts.'),
          )
        else
          ...alertProvider.alerts.take(3).map((alert) {
            Color riskColor = AppColors.riskLow;
            if (alert.severity == RiskLevel.high) riskColor = AppColors.riskHigh;
            if (alert.severity == RiskLevel.moderate) riskColor = AppColors.riskModerate;
            
            return AppCard(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.warning_amber_rounded, color: riskColor),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cow ${alert.cowId}', style: AppTextStyles.h3),
                          const SizedBox(height: 4),
                          Text(alert.message, style: AppTextStyles.bodySmall.copyWith(color: riskColor)),
                        ],
                      ),
                    ),
                    Text(AppLocalizations.of(context).translate('2h_ago') ?? '2h ago', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _GlanceCard extends StatelessWidget {
  final String title;
  final String value;
  final bool isHighlight;

  const _GlanceCard({required this.title, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Text(
            title, 
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.2), 
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value, 
            style: AppTextStyles.h2.copyWith(color: isHighlight ? AppColors.riskHigh : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
