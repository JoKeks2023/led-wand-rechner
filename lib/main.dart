import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/local_database_service.dart';
import 'services/localization_service.dart';
import 'services/supabase_sync_service.dart';
import 'services/auth_service.dart';
import 'providers/app_providers.dart';
import 'ui/screens/main_screen.dart';
import 'ui/theme/app_theme.dart';

const String supabaseUrl = 'YOUR_SUPABASE_URL'; // Setze Supabase URL
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Setze Supabase Anon Key

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Initialize Local Database (Hive)
  await LocalDatabaseService().initialize();

  // Initialize Localization
  await localization.initialize();

  // Initialize Auth Service
  await authService.initialize(Supabase.instance.client);

  // Initialize Sync Service
  await supabaseSyncService.initialize(
    Supabase.instance.client,
    LocalDatabaseService(),
  );

  runApp(const LEDWandCalculatorApp());
}

class LEDWandCalculatorApp extends StatelessWidget {
  const LEDWandCalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProjectsProvider>(
          create: (_) => ProjectsProvider()..initialize(),
        ),
        ChangeNotifierProvider<LEDDataProvider>(
          create: (_) => LEDDataProvider()..initialize(),
        ),
        ChangeNotifierProvider<CalculationProvider>(
          create: (_) => CalculationProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),
      ],
      child: MaterialApp(
        title: localization.appTitle,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
