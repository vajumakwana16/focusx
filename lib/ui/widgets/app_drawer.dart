import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusx/ui/screens/google_sign_in_page.dart';
import 'package:focusx/ui/screens/settings_page.dart';
import 'package:focusx/utils/extensions.dart';

import '../../services/auth_service.dart';
import '../../utils/webservice.dart';

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
            _DrawerHeader(
              name: isGuest ? 'Guest User' : user.displayName ?? 'User',
              email: isGuest
                  ? 'Sign in to save your data'
                  : user.email ?? '',
              photoUrl: user?.photoURL,
              isGuest: isGuest,
            ),

            const SizedBox(height: 8),

            // User stats row
            FutureBuilder<Map<String, dynamic>>(
              future: Webservice.firebaseService.getTodayTaskStats(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final d = snapshot.data!;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _MiniStatCol(
                          value: '${d['completedToday']}',
                          label: 'Today',
                          color: theme.colorScheme.primary,
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                        _MiniStatCol(
                          value: '${d['score']}/10',
                          label: 'Score',
                          color: theme.colorScheme.secondary,
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                        ),
                        _MiniStatCol(
                          value: d['status'].toString().split(' ').first,
                          label: 'Status',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const Divider(),

            _DrawerItem(
              icon: Icons.settings_rounded,
              title: 'Settings',
              onTap: () {
                context.back();
                context.next(const SettingsPage());
              },
            ),

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

            const Spacer(),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'FocusX v1.0.1',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCol extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _MiniStatCol({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
                fontSize: 10,
              ),
        ),
      ],
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage:
                photoUrl != null ? NetworkImage(photoUrl!) : null,
            child: photoUrl == null
                ? Icon(
                    isGuest ? Icons.person_outline : Icons.person,
                    size: 36,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
          if (isGuest) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Guest Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
