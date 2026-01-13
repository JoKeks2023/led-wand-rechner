import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/local_database_service.dart';
import 'services/localization_service.dart';
import 'services/supabase_sync_service.dart';
import 'services/auth_service.dart';
import 'providers/app_providers.dart';
import 'ui/screens/app_navigation_shell.dart';
import 'ui/theme/app_theme.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with config
  await SupabaseConfig.initialize();

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
        // LED Providers
        ChangeNotifierProvider<ProjectsProvider>(
          create: (_) => ProjectsProvider()..initialize(),
        ),
        ChangeNotifierProvider<LEDDataProvider>(
          create: (_) => LEDDataProvider()..initialize(),
        ),
        ChangeNotifierProvider<CalculationProvider>(
          create: (_) => CalculationProvider(),
        ),
        // Auth & Connectivity
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<ConnectivityProvider>(
          create: (_) => ConnectivityProvider(),
        ),
        // DMX Providers
        ChangeNotifierProvider<DMXProfilesProvider>(
          create: (_) => DMXProfilesProvider(),
        ),
        ChangeNotifierProvider<DMXServiceProvider>(
          create: (_) => DMXServiceProvider(),
        ),
        ChangeNotifierProvider<GDTFServiceProvider>(
          create: (_) => GDTFServiceProvider(),
        ),
        ChangeNotifierProvider<GrandMA3DiscoveryProvider>(
          create: (_) => GrandMA3DiscoveryProvider(),
        ),
        ChangeNotifierProvider<GrandMA3ConnectionProvider>(
          create: (_) => GrandMA3ConnectionProvider(),
        ),
        ChangeNotifierProvider<DMXPreferencesProvider>(
          create: (_) => DMXPreferencesProvider(),
        ),
      ],
      child: MaterialApp(
        title: localization.appTitle,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AppNavigationShell(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
