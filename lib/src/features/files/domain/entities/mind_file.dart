import 'package:equatable/equatable.dart';

class MindFile extends Equatable {
  const MindFile({
    required this.id,
    required this.originalName,
    required this.mimeType,
    required this.fileType,
    required this.fileSize,
  });

  final String id;
  final String originalName;
  final String mimeType;
  final String fileType;
  final int fileSize;

  @override
  List<Object?> get props => [id, originalName, mimeType, fileType, fileSize];
}
