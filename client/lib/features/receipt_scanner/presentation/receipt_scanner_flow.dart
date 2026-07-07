import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:client/features/cash_log/data/cash_log_repository.dart';

class ReceiptScannerFlow {
  final WidgetRef ref;
  final BuildContext context;
  final List<Map<String, dynamic>> wallets;
  final VoidCallback onCompleted;

  ReceiptScannerFlow({
    required this.ref,
    required this.context,
    required this.wallets,
    required this.onCompleted,
  });

  final ImagePicker _picker = ImagePicker();

  Future<void> startScanFlow(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image == null) return;

      _showLoadingDialog();

      // Perform multipart upload
      final bytes = await image.readAsBytes();
      final formData = dio.FormData.fromMap({
        'receipt': dio.MultipartFile.fromBytes(
          bytes,
          filename: image.name,
        ),
      });

      final client = ref.read(dioClientProvider);
      final response = await client.post('/api/v1/receipts/scan', data: formData);

      // Dismiss loading
      if (context.mounted) {
        Navigator.pop(context);
      }

      response.fold(
        (failure) {
          _showErrorSnackBar('Upload failed: ${failure.message}');
        },
        (success) {
          final data = success.data;
          if (data is Map) {
            _showConfirmationModal(Map<String, dynamic>.from(data));
          } else {
            _showErrorSnackBar('Invalid response format');
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading if it was open
      }
      _showErrorSnackBar('Error starting scan: $e');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF6200EE)),
                SizedBox(height: 16),
                Text('AI Parsing Receipt...', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showConfirmationModal(Map<String, dynamic> parsedData) {
    final double amount = parsedData['amount']?.toDouble() ?? 0.0;
    final String category = parsedData['category'] ?? 'makan';
    final String merchant = parsedData['merchant'] ?? 'Merchant';

    String? selectedWalletID;
    if (wallets.isNotEmpty) {
      selectedWalletID = wallets[0]['id'];
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Confirm AI Scan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Merchant', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text(merchant, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    title: const Text('Parsed Category', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    title: const Text('Amount Detected', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    subtitle: Text('Rp ${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6200EE))),
                  ),
                  const SizedBox(height: 12),
                  if (wallets.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Select Account/Wallet', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButton<String>(
                        value: selectedWalletID,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2C2C2C),
                        items: wallets.map((w) {
                          return DropdownMenuItem<String>(
                            value: w['id'],
                            child: Text('${w['name']} (Rp ${w['balance']})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setModalState(() {
                            selectedWalletID = val;
                          });
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        final repo = ref.read(cashLogRepositoryProvider);
                        final result = await repo.createCashLog(
                          amount: amount,
                          category: category,
                          type: 'EXPENSE',
                          walletID: selectedWalletID,
                          description: 'Scanned from $merchant',
                        );

                        if (context.mounted) {
                          Navigator.pop(context); // Dismiss sheet
                        }

                        result.fold(
                          (failure) {
                            _showErrorSnackBar('Failed saving: ${failure.message}');
                          },
                          (success) {
                            onCompleted();
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6200EE),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Confirm & Save Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showErrorSnackBar(String msg) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }
}
