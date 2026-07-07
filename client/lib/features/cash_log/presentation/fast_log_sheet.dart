import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/features/cash_log/data/cash_log_repository.dart';

class FastLogSheet extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> wallets;
  final VoidCallback onSaved;

  const FastLogSheet({
    super.key,
    required this.wallets,
    required this.onSaved,
  });

  @override
  ConsumerState<FastLogSheet> createState() => _FastLogSheetState();
}

class _FastLogSheetState extends ConsumerState<FastLogSheet> {
  String _amountStr = '0';
  String _selectedCategory = 'makan';
  String? _selectedWalletID;
  bool _isSaving = false;

  final List<String> _categories = ['makan', 'kopi', 'angkot', 'jajan', 'stealth'];

  @override
  void initState() {
    super.initState();
    if (widget.wallets.isNotEmpty) {
      _selectedWalletID = widget.wallets[0]['id'];
    }
  }

  void _onKeyPress(String val) {
    setState(() {
      if (_amountStr == '0') {
        _amountStr = val;
      } else {
        _amountStr += val;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountStr.length <= 1) {
        _amountStr = '0';
      } else {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      }
    });
  }

  Future<void> _saveTransaction() async {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    if (amount <= 0) return;

    setState(() {
      _isSaving = true;
    });

    final repo = ref.read(cashLogRepositoryProvider);
    final result = await repo.createCashLog(
      amount: amount,
      category: _selectedCategory,
      type: 'EXPENSE',
      walletID: _selectedWalletID,
      description: 'Logged via Fast Log',
    );

    setState(() {
      _isSaving = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${failure.message}')),
        );
      },
      (success) {
        widget.onSaved();
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Fast Cash Log',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (widget.wallets.isNotEmpty)
                DropdownButton<String>(
                  value: _selectedWalletID,
                  dropdownColor: const Color(0xFF2C2C2C),
                  underline: const SizedBox(),
                  items: widget.wallets.map((w) {
                    return DropdownMenuItem<String>(
                      value: w['id'],
                      child: Text('${w['name']} (${w['type']})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedWalletID = val;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Amount Display
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Rp $_amountStr',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6200EE)),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 12),
          // Categories list
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final active = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: active,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      }
                    },
                    selectedColor: const Color(0xFF6200EE),
                    backgroundColor: const Color(0xFF2C2C2C),
                    labelStyle: TextStyle(
                      color: active ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Keypad Layout
          Table(
            children: [
              TableRow(
                children: [
                  _buildKeypadButton('1'),
                  _buildKeypadButton('2'),
                  _buildKeypadButton('3'),
                ],
              ),
              TableRow(
                children: [
                  _buildKeypadButton('4'),
                  _buildKeypadButton('5'),
                  _buildKeypadButton('6'),
                ],
              ),
              TableRow(
                children: [
                  _buildKeypadButton('7'),
                  _buildKeypadButton('8'),
                  _buildKeypadButton('9'),
                ],
              ),
              TableRow(
                children: [
                  _buildKeypadButton('000'),
                  _buildKeypadButton('0'),
                  IconButton(
                    icon: const Icon(Icons.backspace_outlined, size: 28, color: Colors.white),
                    onPressed: _onBackspace,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6200EE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Log Transaction', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String label) {
    return InkWell(
      onTap: () => _onKeyPress(label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
