import 'package:client/core/network/dio_client.dart';
import 'package:client/core/storage/local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

class CashLogRepository {
  final DioClient _dioClient;
  final LocalStorageService _localStorage;

  CashLogRepository(this._dioClient, this._localStorage);

  // Fetch all wallets (remote with mock local fallback)
  Future<Either<Failure, List<Map<String, dynamic>>>> getWallets() async {
    final response = await _dioClient.get('/api/v1/wallets');
    return response.fold(
      (failure) {
        // Fallback to static mock local wallets if server is unreachable
        return Either.right([
          {'id': 'wallet-cash', 'name': 'Dompet Cash', 'type': 'CASH', 'balance': 150000.0, 'currency': 'IDR'},
          {'id': 'wallet-bank', 'name': 'Bank Mandiri', 'type': 'BANK', 'balance': 2450000.0, 'currency': 'IDR'},
          {'id': 'wallet-gopay', 'name': 'GoPay', 'type': 'EWALLET', 'balance': 85000.0, 'currency': 'IDR'},
        ]);
      },
      (res) {
        final data = res.data;
        if (data is List) {
          return Either.right(data.map((e) => Map<String, dynamic>.from(e)).toList());
        }
        return Either.left(Failure('Invalid response data type'));
      },
    );
  }

  // Fetch cash logs (with offline caching sync helper)
  Future<Either<Failure, List<Map<String, dynamic>>>> getCashLogs() async {
    final response = await _dioClient.get('/api/v1/cash-logs');
    return response.fold(
      (failure) {
        // Retrieve local cache
        final cached = _localStorage.getCachedCashLogs();
        if (cached.isNotEmpty) {
          return Either.right(cached);
        }
        // Static mockup fallback
        return Either.right([
          {'id': '1', 'amount': 15000.0, 'category': 'makan', 'type': 'EXPENSE', 'transaction_date': '2026-07-07'},
          {'id': '2', 'amount': 25000.0, 'category': 'kopi', 'type': 'EXPENSE', 'transaction_date': '2026-07-07'},
        ]);
      },
      (res) {
        final data = res.data;
        if (data is List) {
          final mapped = data.map((e) => Map<String, dynamic>.from(e)).toList();
          _localStorage.cacheCashLogs(mapped);
          return Either.right(mapped);
        }
        return Either.left(Failure('Invalid response data type'));
      },
    );
  }

  // Create Wallet remote
  Future<Either<Failure, Map<String, dynamic>>> createWallet({
    required String name,
    required String type,
    required double balance,
  }) async {
    final response = await _dioClient.post('/api/v1/wallets', data: {
      'name': name,
      'type': type,
      'balance': balance,
      'currency': 'IDR',
    });
    return response.map((r) => Map<String, dynamic>.from(r.data as Map));
  }

  // Create Cash Log (with offline queue fallback)
  Future<Either<Failure, Map<String, dynamic>>> createCashLog({
    required double amount,
    required String category,
    required String type,
    String? walletID,
    String? description,
  }) async {
    final payload = {
      'wallet_id': walletID,
      'amount': amount,
      'type': type,
      'category': category,
      'description': description,
    };

    final response = await _dioClient.post('/api/v1/cash-logs', data: payload);
    return response.fold(
      (failure) async {
        // Store in local Hive queue for later sync
        await _localStorage.addToOfflineQueue(payload);
        return Either.right({
          'id': 'offline-queued',
          'amount': amount,
          'category': category,
          'type': type,
          'wallet_id': walletID,
          'description': description,
          'status': 'offline_queued',
        });
      },
      (res) {
        return Either.right(Map<String, dynamic>.from(res.data as Map));
      },
    );
  }

  // Synchronize queued offline logs to backend
  Future<void> syncOfflineQueue() async {
    final queue = _localStorage.getOfflineQueue();
    if (queue.isEmpty) return;

    final failedItems = <Map<String, dynamic>>[];

    for (final item in queue) {
      final res = await _dioClient.post('/api/v1/cash-logs', data: item);
      if (res.isLeft()) {
        failedItems.add(item);
      }
    }

    await _localStorage.clearOfflineQueue();
    for (final failed in failedItems) {
      await _localStorage.addToOfflineQueue(failed);
    }
  }
}

// Singletons for injection
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  // Return initialized instance. In main we do boot setup.
  return LocalStorageService();
});

final cashLogRepositoryProvider = Provider<CashLogRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  // Re-use active storage service
  final storage = LocalStorageService(); 
  return CashLogRepository(dio, storage);
});
