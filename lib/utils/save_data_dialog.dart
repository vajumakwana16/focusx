import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SaveDataDialog extends StatelessWidget {
  const SaveDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_done_rounded,
                size: 48, color: theme.colorScheme.primary),

            const SizedBox(height: 16),

            Text(
              'Save your data securely',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'You are using guest mode.\nSign in to sync tasks & habits across devices.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await AuthService().linkGuestWithGoogle();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save with Google'),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
          ],
        ),
      ),
    );
  }
}