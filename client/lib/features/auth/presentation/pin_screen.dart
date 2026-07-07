import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/auth/auth_service.dart';

class PinScreen extends ConsumerStatefulWidget {
  final bool isSetup;

  const PinScreen({super.key, required this.isSetup});

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  final List<String> _pin = [];
  final int _pinLength = 6;

  void _onKeyPress(String val) {
    if (_pin.length < _pinLength) {
      setState(() {
        _pin.add(val);
      });
      if (_pin.length == _pinLength) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
      });
    }
  }

  Future<void> _submitPin() async {
    final pinStr = _pin.join();
    if (widget.isSetup) {
      await ref.read(authServiceProvider.notifier).setupPin(pinStr);
    } else {
      final success = await ref.read(authServiceProvider.notifier).verifyPin(pinStr);
      if (!success) {
        setState(() {
          _pin.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => ref.read(authServiceProvider.notifier).logout(),
                ),
              ),
              const Spacer(),
              Text(
                widget.isSetup ? 'Setup Security PIN' : 'Enter Security PIN',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isSetup
                    ? 'Create a 6-digit PIN to secure your Stealth data.'
                    : 'Stealth and Dashboard locked.',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Dots display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pinLength, (index) {
                  final filled = index < _pin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? const Color(0xFF6200EE) : Colors.grey[800],
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                  );
                }),
              ),
              if (authState.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  authState.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              // Custom keypad
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    final List<List<String>> keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      children: [
        ...keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              return _buildKeyButton(key, () => _onKeyPress(key));
            }).toList(),
          );
        }),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Biometrics fallback trigger button
            widget.isSetup
                ? const SizedBox(width: 80, height: 80)
                : SizedBox(
                    width: 80,
                    height: 80,
                    child: IconButton(
                      icon: const Icon(Icons.fingerprint, size: 36, color: Color(0xFF6200EE)),
                      onPressed: () => ref
                          .read(authServiceProvider.notifier)
                          .authenticateWithBiometrics(),
                    ),
                  ),
            _buildKeyButton('0', () => _onKeyPress('0')),
            SizedBox(
              width: 80,
              height: 80,
              child: IconButton(
                icon: const Icon(Icons.backspace_outlined),
                onPressed: _onBackspace,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildKeyButton(String label, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      width: 80,
      height: 80,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: BorderSide(color: Colors.grey[800]!),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
