import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import 'led_calculator_screen.dart';
import 'dmx_settings_screen.dart';
import 'dmx_pult_screen.dart';
import 'stage_visualizer_screen.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({Key? key}) : super(key: key);

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _currentIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_navigatorKeys[_currentIndex].currentState?.canPop() ?? false) {
          _navigatorKeys[_currentIndex].currentState?.pop();
          return false;
        }
        return true;
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
          ],
        ),
      ),
    );
  }
}
