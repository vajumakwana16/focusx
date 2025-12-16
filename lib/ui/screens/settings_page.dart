import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../provider/haptic_provider.dart';
import '../../provider/theme_provider.dart';
import '../../services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 ACCOUNT CARD
          _SettingsCard(
            title: 'Account',
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  backgroundImage: user?.photoURL! != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL! == null
                      ? Icon(
                          user?.isAnonymous == true ? Icons.person_outline : Icons.person,
                          size: 32,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                title: Text(
                  user?.isAnonymous == true
                      ? 'Guest User'
                      : user?.displayName ?? 'User',
                ),
                subtitle: FittedBox(
                  child: Text(
                    user?.isAnonymous == true
                        ? 'Not signed in'
                        : user?.email ?? '',
                  ),
                ),
              ),

              if (user?.isAnonymous == true)
                _ActionTile(
                  icon: Icons.cloud_upload,
                  title: 'Save your data',
                  subtitle: 'Sign in with Google',
                  onTap: () async {
                    await AuthService().linkGuestWithGoogle();
                  },
                ),
            ],
          ),

          const SizedBox(height: 16),

          // 🎨 PREFERENCES CARD
          _SettingsCard(
            title: 'Preferences',
            children: [
              _ActionTile(
                icon: Icons.color_lens_outlined,
                title: 'Theme',
                subtitle: 'Light • Dark • System',
                onTap: () {
                  _showThemePicker(context);
                },
              ),

              Consumer<HapticProvider>(
                builder: (context, haptic, _) {
                  return SwitchListTile(
                    title: const Text('Haptic Feedback'),
                    subtitle: const Text('Vibration on taps & actions'),
                    value: haptic.enabled,
                    onChanged: (v) {
                      haptic.setEnabled(v);
                      if (v) {
                        HapticFeedback.selectionClick();
                      }
                    },
                    secondary: const Icon(Icons.vibration),
                  );
                },
              ),

              // _ActionTile(
              //   icon: Icons.notifications_outlined,
              //   title: 'Notifications',
              //   subtitle: 'Task & habit reminders',
              //   onTap: () {
              //     // later: notification settings
              //   },
              // ),
            ],
          ),

          const SizedBox(height: 16),

          // ⚙️ APP CARD
          _SettingsCard(
            title: 'App',
            children: [
              _ActionTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'FocusX productivity app',
                onTap: () {},
              ),

              _ActionTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Logout from this device',
                isDestructive: true,
                onTap: () async {
                  await AuthService().signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🎨 THEME PICKER
  void _showThemePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      builder: (_) {
        final provider = context.watch<ThemeProvider>();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              return RadioListTile<ThemeMode>(
                value: mode,
                groupValue: provider.themeMode,
                title: Text(
                  mode.name[0].toUpperCase() + mode.name.substring(1),
                ),
                onChanged: (m) {
                  provider.setTheme(m!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Colors.redAccent
        : Theme.of(context).colorScheme.primary;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}