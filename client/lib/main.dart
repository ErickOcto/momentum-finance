import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/storage/local_storage.dart';
import 'package:client/core/auth/auth_service.dart';
import 'package:client/features/auth/presentation/login_screen.dart';
import 'package:client/features/auth/presentation/pin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final localStorage = LocalStorageService();
  await localStorage.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authServiceProvider);

    Widget getHomeScreen() {
      switch (authState.status) {
        case AuthStatus.unauthenticated:
          return const LoginScreen();
        case AuthStatus.needsPinSetup:
          return const PinScreen(isSetup: true);
        case AuthStatus.needsPinVerification:
          return const PinScreen(isSetup: false);
        case AuthStatus.authenticated:
          return const DashboardSkeleton();
      }
    }

    return MaterialApp(
      title: 'Momentum Finance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6200EE),
          brightness: Brightness.dark,
        ),
      ),
      home: getHomeScreen(),
    );
  }
}

class DashboardSkeleton extends ConsumerWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum Finance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => ref.read(authServiceProvider.notifier).logout(),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 72,
                color: Color(0xFF6200EE),
              ),
              const SizedBox(height: 16),
              Text(
                'Momentum Finance MVP Skeleton',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Clean Architecture + Riverpod skeleton configured successfully.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
