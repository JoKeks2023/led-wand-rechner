import 'package:flutter/material.dart';
import 'package:led_wand_app/ui/theme/app_colors.dart';
import 'package:led_wand_app/ui/screens/led_calculator_screen.dart';
import 'package:led_wand_app/ui/screens/dmx_settings_screen.dart';
import 'package:led_wand_app/ui/screens/stage_visualizer_screen.dart';
import 'package:led_wand_app/ui/screens/device_catalog_screen.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    final canPopCurrent =
        _navigatorKeys[_currentIndex].currentState?.canPop() ?? false;

    return PopScope(
      canPop: !canPopCurrent,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (canPopCurrent) {
          _navigatorKeys[_currentIndex].currentState?.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // LED Calculator
            Navigator(
              key: _navigatorKeys[0],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (_) => const LEDCalculatorScreen(),
                );
              },
            ),
            // DMX Settings
            Navigator(
              key: _navigatorKeys[1],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (_) => const DMXSettingsScreen(),
                );
              },
            ),
            // Stage Visualizer
            Navigator(
              key: _navigatorKeys[2],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (_) => const StageVisualizerScreen(),
                );
              },
            ),
            // Device Catalog
            Navigator(
              key: _navigatorKeys[3],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (_) => const DeviceCatalogScreen(),
                );
              },
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.neutral500,
          backgroundColor: Colors.white,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'LED Rechner',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'DMX',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.landscape),
              label: 'Bühne',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: 'Katalog',
            ),
          ],
        ),
      ),
    );
  }
}
