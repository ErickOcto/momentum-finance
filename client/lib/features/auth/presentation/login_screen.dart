import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/auth/auth_service.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: Color(0xFF6200EE),
              ),
              const SizedBox(height: 24),
              Text(
                'Momentum Finance',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Budgeting is dead. Track reality.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (authState.error != null) ...[
                Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: () => ref
                    .read(authServiceProvider.notifier)
                    .loginWithMockProvider('student@univ.edu'),
                icon: const Icon(Icons.email_outlined),
                label: const Text('Continue with Email'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => ref
                    .read(authServiceProvider.notifier)
                    .loginWithMockProvider('google-student@univ.edu'),
                icon: const Icon(Icons.login),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => ref
                    .read(authServiceProvider.notifier)
                    .loginWithMockProvider('apple-student@univ.edu'),
                icon: const Icon(Icons.apple),
                label: const Text('Continue with Apple'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
