import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'routes/app_router.dart';
import '../core/utils/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/farm_provider.dart';
import '../providers/herd_provider.dart';
import '../providers/cow_provider.dart';
import '../providers/prediction_provider.dart';
import '../providers/smart_milk_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/feedback_provider.dart';
import '../providers/localization_provider.dart';

class SihMastitisApp extends StatelessWidget {
  const SihMastitisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalizationProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FarmProvider()),
        ChangeNotifierProvider(create: (_) => HerdProvider()),
        ChangeNotifierProvider(create: (_) => CowProvider()),
        ChangeNotifierProvider(create: (_) => PredictionProvider()),
        ChangeNotifierProvider(create: (_) => SmartMilkProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => FeedbackProvider()),
      ],
      child: Consumer<LocalizationProvider>(
        builder: (context, localizationProvider, _) {
          return MaterialApp.router(
            title: 'MastiQ',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            supportedLocales: const [
              Locale('en'),
              Locale('ta'),
              Locale('hi'),
              Locale('ml'),
              Locale('te'),
              Locale('kn'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: localizationProvider.locale,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
