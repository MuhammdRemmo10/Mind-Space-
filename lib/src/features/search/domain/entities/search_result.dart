import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
  });

  final String id;
  final String type;
  final String title;
  final String? subtitle;

  @override
  List<Object?> get props => [id, type, title, subtitle];
}
