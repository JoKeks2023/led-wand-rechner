import 'package:flutter/material.dart';
import 'ui/screens/app_navigation_shell.dart';
import 'ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LEDWandCalculatorApp());
}

class LEDWandCalculatorApp extends StatelessWidget {
  const LEDWandCalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Wand Rechner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const AppNavigationShell(),
    );
  }
}
