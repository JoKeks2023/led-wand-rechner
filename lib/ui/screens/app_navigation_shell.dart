import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../services/localization_service.dart';
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
            // DMX Console
            Navigator(
              key: _navigatorKeys[1],
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (_) => _DMXNavigationShell(),
                );
              },
            ),
            // Stage
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
        bottomNavigationBar: _ModernBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _DMXNavigationShell extends StatefulWidget {
  const _DMXNavigationShell();

  @override
  State<_DMXNavigationShell> createState() => _DMXNavigationShellState();
}

class _DMXNavigationShellState extends State<_DMXNavigationShell> {
  int _dmxSubIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _dmxSubIndex,
        children: [
          const DMXPultScreen(),
          const DMXSettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        child: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.dashboard),
              label: localization.translate('dmx.pult'),
              tooltip: localization.translate('dmx.pult'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings),
              label: localization.translate('dmx.settings'),
              tooltip: localization.translate('dmx.settings'),
            ),
          ],
          selectedIndex: _dmxSubIndex,
          onDestinationSelected: (index) {
            setState(() {
              _dmxSubIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ModernBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: _NavIcon(
                icon: Icons.calculate,
                label: localization.translate('nav.led'),
                isSelected: currentIndex == 0,
              ),
              label: localization.translate('nav.led'),
              tooltip: localization.translate('nav.led_calculator'),
            ),
            NavigationDestination(
              icon: _NavIcon(
                icon: Icons.devices_other,
                label: localization.translate('nav.dmx'),
                isSelected: currentIndex == 1,
              ),
              label: localization.translate('nav.dmx'),
              tooltip: localization.translate('nav.dmx_console'),
            ),
            NavigationDestination(
              icon: _NavIcon(
                icon: Icons.theater_comedy,
                label: localization.translate('nav.stage'),
                isSelected: currentIndex == 2,
              ),
              label: localization.translate('nav.stage'),
              tooltip: localization.translate('nav.stage_visualizer'),
            ),
          ],
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Theme.of(context).colorScheme.primaryContainer,
          indicatorColor: AppColors.primary.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _NavIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Icon(icon),
    );
  }
}
