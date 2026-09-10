import 'package:flutter/material.dart';
import 'app/app.dart';
import 'services/api/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.loadToken();
  runApp(const SihMastitisApp());
}
