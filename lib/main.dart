import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:led_wand_app/ui/screens/app_navigation_shell.dart';
import 'package:led_wand_app/ui/theme/app_theme.dart';
import 'package:led_wand_app/providers/app_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: LEDWandCalculatorApp()));
}

class LEDWandCalculatorApp extends ConsumerWidget {
  const LEDWandCalculatorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'LED Wand Rechner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode == 'light'
          ? ThemeMode.light
          : themeMode == 'dark'
              ? ThemeMode.dark
              : ThemeMode.system,
      home: const AppNavigationShell(),
    );
  }
}
