import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

enum AuthStatus {
  unauthenticated,
  needsPinSetup,
  needsPinVerification,
  authenticated,
}

class AuthState {
  final AuthStatus status;
  final String? email;
  final String? error;

  AuthState({
    required this.status,
    this.email,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? email,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
      error: error ?? this.error,
    );
  }
}

class AuthService extends StateNotifier<AuthState> {
  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  AuthService() : super(AuthState(status: AuthStatus.unauthenticated)) {
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final token = await _secureStorage.read(key: 'clerk_token');
    if (token == null) {
      state = AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    final pin = await _secureStorage.read(key: 'secure_pin');
    if (pin == null) {
      state = AuthState(status: AuthStatus.needsPinSetup);
    } else {
      state = AuthState(status: AuthStatus.needsPinVerification);
    }
  }

  // Social Auth simulation (saves mock JWT to secure storage)
  Future<void> loginWithMockProvider(String email) async {
    try {
      await _secureStorage.write(key: 'clerk_token', value: 'mock_jwt_token_for_$email');
      final pin = await _secureStorage.read(key: 'secure_pin');
      if (pin == null) {
        state = AuthState(status: AuthStatus.needsPinSetup, email: email);
      } else {
        state = AuthState(status: AuthStatus.needsPinVerification, email: email);
      }
    } catch (e) {
      state = state.copyWith(error: 'Login failed: $e');
    }
  }

  // PIN Registration
  Future<void> setupPin(String pin) async {
    if (pin.length != 6) {
      state = state.copyWith(error: 'PIN must be exactly 6 digits');
      return;
    }

    try {
      await _secureStorage.write(key: 'secure_pin', value: pin);
      state = AuthState(status: AuthStatus.authenticated, email: state.email);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save PIN: $e');
    }
  }

  // PIN Verification
  Future<bool> verifyPin(String pin) async {
    try {
      final savedPin = await _secureStorage.read(key: 'secure_pin');
      if (savedPin == pin) {
        state = AuthState(status: AuthStatus.authenticated, email: state.email);
        return true;
      }
      state = state.copyWith(error: 'Invalid PIN entered');
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Verification failed: $e');
      return false;
    }
  }

  // Biometrics Verification fallback
  Future<void> authenticateWithBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!isAvailable) {
        state = state.copyWith(error: 'Biometric authentication unavailable');
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock Momentum Finance using biometrics',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        state = AuthState(status: AuthStatus.authenticated, email: state.email);
      } else {
        state = state.copyWith(error: 'Biometric verification failed');
      }
    } catch (e) {
      state = state.copyWith(error: 'Biometric error: $e');
    }
  }

  // Clears all stored auth keys
  Future<void> logout() async {
    await _secureStorage.deleteAll();
    state = AuthState(status: AuthStatus.unauthenticated);
  }
}

final authServiceProvider = StateNotifierProvider<AuthService, AuthState>((ref) {
  return AuthService();
});
