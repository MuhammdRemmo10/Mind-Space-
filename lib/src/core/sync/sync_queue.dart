import 'sync_operation.dart';

abstract class SyncQueue {
  Future<void> enqueue(SyncOperation operation);
  Future<List<SyncOperation>> pendingOperations({int limit = 50});
  Future<void> markSynced(String operationId);
  Future<void> clear();
}
