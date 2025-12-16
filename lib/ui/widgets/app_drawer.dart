import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusx/ui/screens/google_sign_in_page.dart';
import 'package:focusx/ui/screens/settings_page.dart';
import 'package:focusx/utils/extensions.dart';

import '../../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user == null || user.isAnonymous;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // 🔝 ACCOUNT HEADER
            _DrawerHeader(
              name: isGuest ? 'Guest User' : user.displayName ?? 'User',
              email: isGuest ? 'Sign in to save your data' : user.email ?? '',
              photoUrl: user?.photoURL,
              isGuest: isGuest,
            ),

            const SizedBox(height: 8),

            /* // 📂 NAVIGATION
            _DrawerItem(
              icon: Icons.dashboard_rounded,
              title: 'Home',
              onTap: () => context.read<DashboardProvider>().setIndex(0),
            ),
            _DrawerItem(
              icon: Icons.checklist_rounded,
              title: 'Tasks',
              onTap: () => context.read<DashboardProvider>().setIndex(1),
            ),
            _DrawerItem(
              icon: Icons.repeat_rounded,
              title: 'Habits',
              onTap: () => context.read<DashboardProvider>().setIndex(2),
            ),
            _DrawerItem(
              icon: Icons.bar_chart_rounded,
              title: 'Analytics',
              onTap: () => context.read<DashboardProvider>().setIndex(3),
            ),

            const Spacer(),*/
            // const Divider(),

            // ⚙️ SETTINGS
            _DrawerItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              onTap: () {
                context.back();
                context.next(SettingsPage());
              },
            ),

            // 🔐 AUTH ACTION
            _DrawerItem(
              icon: isGuest ? Icons.login_rounded : Icons.logout_rounded,
              title: isGuest ? 'Sign in' : 'Sign out',
              isDestructive: !isGuest,
              onTap: () async {
                Navigator.pop(context);

                if (isGuest) {
                  context.next(GoogleSignInPage());
                } else {
                  await AuthService().signOut();
                }
              },
            ),

            Spacer(),
            const Divider(),
            const SizedBox(height: 12),
            Text("v1.0.13",style: context.textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
 
}

class _DrawerHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final bool isGuest;

  const _DrawerHeader({
    required this.name,
    required this.email,
    this.photoUrl,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.2,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              backgroundImage: photoUrl != null ? NetworkImage(photoUrl!) : null,
              child: photoUrl == null
                  ? Icon(
                isGuest ? Icons.person_outline : Icons.person,
                size: 32,
                color: theme.colorScheme.primary,
              )
                  : null,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? Colors.redAccent
        : Theme.of(context).iconTheme.color;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
    );
  }
}