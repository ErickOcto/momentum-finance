import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/storage/local_storage.dart';
import 'package:client/core/auth/auth_service.dart';
import 'package:client/features/auth/presentation/login_screen.dart';
import 'package:client/features/auth/presentation/pin_screen.dart';

import 'package:client/features/dashboard/presentation/dashboard_screen.dart';

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
          return const DashboardScreen();
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
