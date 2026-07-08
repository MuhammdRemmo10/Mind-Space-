import 'package:equatable/equatable.dart';

enum SyncOperationType { create, update, delete, restore }

class SyncOperation extends Equatable {
  const SyncOperation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.type,
    required this.payload,
    required this.createdAt,
  });

  final String id;
  final String entityType;
  final String entityId;
  final SyncOperationType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    entityType,
    entityId,
    type,
    payload,
    createdAt,
  ];
}
