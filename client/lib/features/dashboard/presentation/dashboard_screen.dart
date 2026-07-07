import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/auth/auth_service.dart';
import 'package:client/features/cash_log/data/cash_log_repository.dart';
import 'package:client/features/cash_log/presentation/fast_log_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<Map<String, dynamic>> _wallets = [];
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final repo = ref.read(cashLogRepositoryProvider);
    
    // Auto-sync offline queue items if any
    await repo.syncOfflineQueue();

    final walletsRes = await repo.getWallets();
    final logsRes = await repo.getCashLogs();

    if (mounted) {
      setState(() {
        _wallets = walletsRes.getOrElse((_) => []);
        _logs = logsRes.getOrElse((_) => []);
        _isLoading = false;
      });
    }
  }

  double _calculateTotalBalance() {
    double total = 0.0;
    for (var w in _wallets) {
      final balance = w['balance'];
      if (balance is num) {
        total += balance.toDouble();
      }
    }
    return total;
  }

  void _showFastLogSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FastLogSheet(
          wallets: _wallets,
          onSaved: _loadData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MOMENTUM',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => ref.read(authServiceProvider.notifier).logout(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF6200EE),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6200EE)))
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Net Balance Card
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  // Wallets Section
                  const Text(
                    'My Wallets',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildWalletsList(),
                  const SizedBox(height: 24),
                  // Transaction History Feed
                  const Text(
                    'History Log',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionHistory(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: _showFastLogSheet,
        backgroundColor: const Color(0xFF6200EE),
        child: const Icon(Icons.add, size: 36, color: Colors.white),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final total = _calculateTotalBalance();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6200EE), Color(0xFF3700B3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x4C6200EE),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Active Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Rp ${total.toStringAsFixed(0)}',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Stealth Vault Locked', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWalletsList() {
    if (_wallets.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No wallets registered.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: _wallets.map((w) {
        IconData icon;
        switch (w['type']) {
          case 'CASH':
            icon = Icons.payments_outlined;
            break;
          case 'BANK':
            icon = Icons.account_balance_outlined;
            break;
          default:
            icon = Icons.account_balance_wallet_outlined;
        }

        final balance = w['balance']?.toDouble() ?? 0.0;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C2C2C)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2C2C2C),
              child: Icon(icon, color: const Color(0xFF6200EE)),
            ),
            title: Text(w['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(w['type'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: Text(
              'Rp ${balance.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransactionHistory() {
    if (_logs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No transactions recorded yet.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: _logs.map((log) {
        final amount = log['amount']?.toDouble() ?? 0.0;
        final type = log['type'] ?? 'EXPENSE';
        final isExpense = type == 'EXPENSE';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2C2C2C)),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isExpense ? const Color.fromRGBO(244, 67, 54, 0.1) : const Color.fromRGBO(76, 175, 80, 0.1),
              child: Icon(
                isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                color: isExpense ? Colors.red : Colors.green,
                size: 20,
              ),
            ),
            title: Text(
              log['category'] ?? 'log',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              log['transaction_date'] ?? 'Today',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Text(
              '${isExpense ? "-" : "+"} Rp ${amount.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
