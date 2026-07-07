import 'dart:io';
import 'package:client/core/storage/local_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalStorageService service;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    service = LocalStorageService();
    await service.init(subDir: tempDir.path);
  });

  tearDown(() async {
    await service.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('should add, retrieve, and clear offline queue', () async {
    final payload1 = {'action': 'CREATE_LOG', 'amount': 50000.0, 'category': 'makan'};
    final payload2 = {'action': 'CREATE_LOG', 'amount': 15000.0, 'category': 'kopi'};

    expect(service.getOfflineQueue(), isEmpty);

    await service.addToOfflineQueue(payload1);
    await service.addToOfflineQueue(payload2);

    final queue = service.getOfflineQueue();
    expect(queue.length, 2);
    expect(queue[0]['category'], 'makan');
    expect(queue[1]['category'], 'kopi');

    await service.clearOfflineQueue();
    expect(service.getOfflineQueue(), isEmpty);
  });

  test('should cache and retrieve cash logs', () async {
    final logs = [
      {'id': '1', 'amount': 25000.0, 'category': 'transport'},
      {'id': '2', 'amount': 12000.0, 'category': 'snack'},
    ];

    expect(service.getCachedCashLogs(), isEmpty);

    await service.cacheCashLogs(logs);

    final cached = service.getCachedCashLogs();
    expect(cached.length, 2);
    expect(cached[0]['category'], 'transport');
    expect(cached[1]['category'], 'snack');
  });
}
