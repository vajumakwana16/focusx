import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../theme/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: user?.isAnonymous == true ?  const Icon(Icons.person) : CircleAvatar(foregroundImage: NetworkImage(user!.photoURL!)),
            title: Text(user?.isAnonymous == true
                ? 'Guest User'
                : user?.email ?? ''),
            subtitle: Text(user?.isAnonymous == true
                ? 'Not signed in'
                : 'Signed in'),
          ),

          if (user?.isAnonymous == true)
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Save your data'),
              subtitle: const Text('Sign in with Google'),
              onTap: () async {
                await AuthService().linkGuestWithGoogle();
              },
            ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            subtitle: const Text('Light / Dark / System'),
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                builder: (_) => const _ThemePicker(),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {},
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              await AuthService().signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }


}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tile(context, provider, ThemeMode.system, 'System'),
        _tile(context, provider, ThemeMode.light, 'Light'),
        _tile(context, provider, ThemeMode.dark, 'Dark'),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _tile(
      BuildContext context,
      ThemeProvider provider,
      ThemeMode mode,
      String label,
      ) {
    return RadioListTile<ThemeMode>(
      value: mode,
      groupValue: provider.themeMode,
      onChanged: (m) {
        provider.setTheme(m!);
        Navigator.pop(context);
      },
      title: Text(label),
    );
  }
}