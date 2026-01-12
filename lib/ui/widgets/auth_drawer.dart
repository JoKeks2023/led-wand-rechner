import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_providers.dart';
import '../../services/localization_service.dart';

class AuthDrawer extends StatelessWidget {
  const AuthDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.brightness_high,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localization.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (authProvider.isAuthenticated) ...[
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profil'),
                  subtitle: Text(authProvider.userEmail ?? ''),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(localization.commonLogout),
                  onTap: () {
                    authProvider.signOut();
                    Navigator.pop(context);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.login),
                  title: Text(localization.authLogin),
                  onTap: () {
                    Navigator.pop(context);
                    _showAuthDialog(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.app_registration),
                  title: Text(localization.authSignUp),
                  onTap: () {
                    Navigator.pop(context);
                    _showAuthDialog(context, isSignUp: true);
                  },
                ),
              ],
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Über diese App'),
                onTap: () {
                  Navigator.pop(context);
                  _showAboutDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAuthDialog(BuildContext context, {bool isSignUp = false}) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isSignUp ? localization.authSignUp : localization.authLogin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: localization.authEmail,
                border: const OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: localization.authPassword,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localization.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              if (isSignUp) {
                await authProvider.signUp(
                  email: emailController.text,
                  password: passwordController.text,
                );
              } else {
                await authProvider.signIn(
                  email: emailController.text,
                  password: passwordController.text,
                );
              }

              if (context.mounted) {
                Navigator.pop(context);
                if (authProvider.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.error!)),
                  );
                }
              }
            },
            child: Text(isSignUp ? localization.authSignUp : localization.authLogin),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: localization.appTitle,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 LED Wand Rechner. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Eine professionelle App zur Berechnung aller relevanten Parameter für LED-Wände.',
        ),
        const SizedBox(height: 16),
        const Text('Features:'),
        const SizedBox(height: 8),
        const Text('• Berechnung von Pixeldichte, Auflösung und Kosten'),
        const Text('• Multi-Plattform-Support (Web, iOS, Android, macOS, Windows)'),
        const Text('• Cloud-Synchronisierung mit lokaler Offline-Unterstützung'),
        const Text('• Community-Model-Sharing'),
        const Text('• PDF/CSV-Export'),
      ],
    );
  }
}
