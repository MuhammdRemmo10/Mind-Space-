import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalSpaces,
    required this.totalNotes,
    required this.totalTasks,
    required this.totalArticles,
    required this.totalFiles,
    required this.totalWordsWritten,
    required this.writingStreak,
    required this.mostActiveSpace,
    required this.mostUsedTags,
    required this.recentNotes,
    required this.recentTasks,
  });

  final int totalSpaces;
  final int totalNotes;
  final int totalTasks;
  final int totalArticles;
  final int totalFiles;
  final int totalWordsWritten;
  final int writingStreak;
  final String mostActiveSpace;
  final List<String> mostUsedTags;
  final List<String> recentNotes;
  final List<String> recentTasks;

  @override
  List<Object?> get props => [
    totalSpaces,
    totalNotes,
    totalTasks,
    totalArticles,
    totalFiles,
    totalWordsWritten,
    writingStreak,
    mostActiveSpace,
    mostUsedTags,
    recentNotes,
    recentTasks,
  ];
}
