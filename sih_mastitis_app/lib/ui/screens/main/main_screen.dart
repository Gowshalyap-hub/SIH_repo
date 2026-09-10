import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sih_mastitis_app/core/utils/app_localizations.dart';
import 'package:sih_mastitis_app/providers/localization_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../dashboard/dashboard_screen.dart';
import '../herd/herd_screen.dart';
import '../alerts/alerts_screen.dart';
import '../analytics/analytics_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LocalizationProvider>();
    final List<Widget> _screens = [
      const DashboardScreen(),
      const HerdScreen(),
      Center(child: Text(AppLocalizations.of(context).translate('add_new_cow_placeholder') ?? '')), // Replace with actual Add Cow screen later
      const AlertsScreen(),
      const AnalyticsScreen(),
    ];

    return Scaffold(
      body: _screens[_currentIndex == 2 ? 0 : _currentIndex], // Avoid rendering FAB tab index directly
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => context.push('/add-cow'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (index) {
          if (index == 2) {
             context.push('/add-cow');
          } else {
             setState(() => _currentIndex = index);
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: AppLocalizations.of(context).translate('home') ?? 'Home'),
          BottomNavigationBarItem(icon: const Icon(Icons.pets), label: AppLocalizations.of(context).translate('herd') ?? 'Herd'),
          BottomNavigationBarItem(icon: const Icon(Icons.add, color: Colors.transparent), label: AppLocalizations.of(context).translate('add') ?? 'Add'),
          BottomNavigationBarItem(icon: const Icon(Icons.notifications_none), label: AppLocalizations.of(context).translate('alerts') ?? 'Alerts'),
          BottomNavigationBarItem(icon: const Icon(Icons.insert_chart_outlined), label: AppLocalizations.of(context).translate('reports') ?? 'Reports'),
        ],
      ),
    );
  }
}
