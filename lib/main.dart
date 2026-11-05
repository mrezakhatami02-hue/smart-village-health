import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartVillageApp());
}

class SmartVillageApp extends StatelessWidget {
  const SmartVillageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Village Health',
      theme: AppTheme.lightTheme,
      home: const WelcomeScreen(),
    );
  }
}
