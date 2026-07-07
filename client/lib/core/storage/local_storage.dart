import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _offlineQueueBoxName = 'offline_queue';
  static const String _cashLogsBoxName = 'cash_logs';

  late Box<Map> _offlineQueueBox;
  late Box<Map> _cashLogsBox;

  // Initialize Hive and open boxes
  Future<void> init({String? subDir}) async {
    if (subDir != null) {
      Hive.init(subDir);
    } else {
      await Hive.initFlutter();
    }

    _offlineQueueBox = await Hive.openBox<Map>(_offlineQueueBoxName);
    _cashLogsBox = await Hive.openBox<Map>(_cashLogsBoxName);
  }

  // --- Offline Queue Operations ---

  // Add payload to offline queue
  Future<void> addToOfflineQueue(Map<String, dynamic> payload) async {
    await _offlineQueueBox.add(payload);
  }

  // Retrieve all payloads in offline queue
  List<Map<String, dynamic>> getOfflineQueue() {
    return _offlineQueueBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // Clear offline queue
  Future<void> clearOfflineQueue() async {
    await _offlineQueueBox.clear();
  }

  // --- Cash Logs Caching Operations ---

  // Cache list of cash logs
  Future<void> cacheCashLogs(List<Map<String, dynamic>> logs) async {
    await _cashLogsBox.clear();
    for (int i = 0; i < logs.length; i++) {
      await _cashLogsBox.put(i, logs[i]);
    }
  }

  // Retrieve cached cash logs
  List<Map<String, dynamic>> getCachedCashLogs() {
    return _cashLogsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  // Close boxes helper for testing resource cleanup
  Future<void> close() async {
    await Hive.close();
  }
}
