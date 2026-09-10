import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../ui/screens/splash/splash_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register_screen.dart';
import '../../ui/screens/main/main_screen.dart';
import '../../ui/screens/dashboard/dashboard_screen.dart';
import '../../ui/screens/herd/herd_screen.dart';
import '../../ui/screens/cow/cow_profile_screen.dart';
import '../../ui/screens/cow/add_cow_screen.dart';
import '../../ui/screens/prediction/prediction_screen.dart';
import '../../ui/screens/prediction/live_prediction_screen.dart';
import '../../ui/screens/smart_milk/smart_milk_rfid_screen.dart';
import '../../ui/screens/smart_milk/smart_milk_connect_screen.dart';
import '../../ui/screens/smart_milk/smart_milk_live_screen.dart';
import '../../ui/screens/smart_milk/smart_milk_review_screen.dart';
import '../../ui/screens/manual_data/manual_data_screen.dart';
import '../../ui/screens/lab_data/lab_data_screen.dart';
import '../../ui/screens/alerts/alerts_screen.dart';
import '../../ui/screens/recommendations/recommendations_screen.dart';
import '../../ui/screens/analytics/analytics_screen.dart';
import '../../ui/screens/feedback/feedback_screen.dart';
import '../../ui/screens/settings/settings_screen.dart';
import '../../ui/screens/settings/farm_profile_screen.dart';
import '../../ui/screens/settings/account_settings_screen.dart';
import '../../ui/screens/settings/notification_settings_screen.dart';
import '../../ui/screens/settings/help_support_screen.dart';
import '../../ui/screens/settings/about_screen.dart';
import '../../models/cow.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/dashboard', builder: (context, state) => const MainScreen(initialIndex: 0)),
      GoRoute(path: '/herd', builder: (context, state) => const MainScreen(initialIndex: 1)),
      GoRoute(path: '/alerts', builder: (context, state) => const MainScreen(initialIndex: 3)),
      GoRoute(path: '/analytics', builder: (context, state) => const MainScreen(initialIndex: 4)),
      
      GoRoute(path: '/add-cow', builder: (context, state) => const AddCowScreen()),
      GoRoute(path: '/cow/:cowId', builder: (context, state) {
        final cowId = state.pathParameters['cowId']!;
        final cow = state.extra as Cow?;
        return CowProfileScreen(cowId: cowId, cow: cow);
      }),
      GoRoute(path: '/prediction/:cowId', builder: (context, state) {
        final cowId = state.pathParameters['cowId']!;
        return PredictionScreen(cowId: cowId);
      }),
      GoRoute(path: '/live-prediction', builder: (context, state) => const LivePredictionScreen()),

      GoRoute(
        path: '/smart-milk',
        builder: (context, state) => const SmartMilkRfidScreen(),
        routes: [
          GoRoute(path: 'rfid', builder: (context, state) => const SmartMilkRfidScreen()),
          GoRoute(path: 'connect', builder: (context, state) => const SmartMilkConnectScreen()),
          GoRoute(path: 'live', builder: (context, state) => const SmartMilkLiveScreen()),
          GoRoute(path: 'review', builder: (context, state) => const SmartMilkReviewScreen()),
        ],
      ),
      GoRoute(path: '/manual-data', builder: (context, state) => const ManualDataScreen()),
      GoRoute(path: '/lab-data', builder: (context, state) => const LabDataScreen()),
      GoRoute(path: '/recommendations', builder: (context, state) => const RecommendationsScreen()),
      GoRoute(path: '/feedback', builder: (context, state) => const FeedbackScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/farm-profile', builder: (context, state) => const FarmProfileScreen()),
      GoRoute(path: '/account-settings', builder: (context, state) => const AccountSettingsScreen()),
      GoRoute(path: '/notification-settings', builder: (context, state) => const NotificationSettingsScreen()),
      GoRoute(path: '/help-support', builder: (context, state) => const HelpSupportScreen()),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
    ],
  );
}
