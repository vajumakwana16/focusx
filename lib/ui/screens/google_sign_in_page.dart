import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class GoogleSignInPage extends StatelessWidget {
  const GoogleSignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // 🌟 App Logo / Icon
              Container(
                height: 96,
                width: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 28),

              // 🧠 Title
              Text(
                'Welcome to FocusX',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // ✨ Subtitle
              Text(
                'Plan smarter. Build habits.\nStay focused every day.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.hintColor,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 48),

              // 🔐 Google Sign-In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/google.png',
                    height: 22,
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    foregroundColor: theme.colorScheme.onSurface,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.dividerColor,
                      ),
                    ),
                  ),
                  onPressed: () async {
                    final user =
                    await AuthService().signInWithGoogle();

                    if (user != null && context.mounted) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/home',
                      );
                    }
                  },
                ),
              ),

              const SizedBox(height: 10),

              // 👤 Continue as Guest
              TextButton(
                onPressed: () async {
                  final user = await AuthService().signInAsGuest();
                  if (user != null && context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),


              const SizedBox(height: 20),

              // 🔒 Privacy note
              Text(
                'We never post anything without your permission.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),

              const Spacer(),

              // 📜 Footer
              Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}