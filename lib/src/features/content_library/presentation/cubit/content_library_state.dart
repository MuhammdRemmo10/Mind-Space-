import 'package:equatable/equatable.dart';

import '../../domain/entities/content_library_item.dart';

sealed class ContentLibraryState extends Equatable {
  const ContentLibraryState();

  @override
  List<Object?> get props => [];
}

class ContentLibraryInitial extends ContentLibraryState {
  const ContentLibraryInitial();
}

class ContentLibraryLoading extends ContentLibraryState {
  const ContentLibraryLoading();
}

class ContentLibraryLoaded extends ContentLibraryState {
  const ContentLibraryLoaded({required this.mode, required this.items});

  final ContentLibraryMode mode;
  final List<ContentLibraryItem> items;

  @override
  List<Object?> get props => [mode, items];
}

class ContentLibraryFailure extends ContentLibraryState {
  const ContentLibraryFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
