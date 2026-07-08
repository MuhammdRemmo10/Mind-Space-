import 'package:equatable/equatable.dart';

import '../../../spaces/domain/entities/space.dart';
import '../../domain/entities/article.dart';

sealed class ArticlesState extends Equatable {
  const ArticlesState();

  @override
  List<Object?> get props => [];
}

class ArticlesInitial extends ArticlesState {
  const ArticlesInitial();
}

class ArticlesLoading extends ArticlesState {
  const ArticlesLoading();
}

class ArticlesLoaded extends ArticlesState {
  const ArticlesLoaded({
    required this.articles,
    required this.spaces,
    this.selectedSpaceId,
    this.allSpaces = false,
  });

  final List<Article> articles;
  final List<Space> spaces;
  final String? selectedSpaceId;
  final bool allSpaces;

  @override
  List<Object?> get props => [articles, spaces, selectedSpaceId, allSpaces];
}

class ArticlesFailure extends ArticlesState {
  const ArticlesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
