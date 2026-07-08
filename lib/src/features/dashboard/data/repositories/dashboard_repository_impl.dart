import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<DashboardSummary> getSummary() async {
    final response = await _dio.get(ApiEndpoints.dashboard);
    final data = ApiResponseParser.unwrapMap(response.data);
    final summary = Map<String, dynamic>.from(
      data['summary'] as Map? ?? const {},
    );
    final recentNotes = data['recent_notes'] as List? ?? const [];
    final recentTasks = data['recent_tasks'] as List? ?? const [];

    return DashboardSummary(
      totalSpaces: _asInt(summary['total_spaces']),
      totalNotes: _asInt(summary['total_notes']),
      totalTasks: _asInt(summary['total_tasks']),
      totalArticles: _asInt(summary['total_articles']),
      totalFiles: _asInt(summary['total_files']),
      totalWordsWritten: _asInt(summary['total_words_written']),
      writingStreak: _asInt(summary['writing_streak']),
      mostActiveSpace: summary['most_active_space'] as String? ?? 'Yok',
      mostUsedTags: const [],
      recentNotes: recentNotes
          .map((item) => (item as Map)['title'] as String? ?? '')
          .where((title) => title.isNotEmpty)
          .toList(),
      recentTasks: recentTasks
          .map((item) => (item as Map)['title'] as String? ?? '')
          .where((title) => title.isNotEmpty)
          .toList(),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
