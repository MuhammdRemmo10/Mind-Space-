import '../error/app_exception.dart';

class ApiResponseParser {
  const ApiResponseParser._();

  static Map<String, dynamic> unwrapMap(dynamic responseData) {
    final envelope = _asMap(responseData);

    if (envelope['success'] == false) {
      throw AppException(envelope['message'] as String? ?? 'İstek başarısız.');
    }

    return _asMap(envelope['data']);
  }

  static List<dynamic> unwrapList(dynamic responseData) {
    final envelope = _asMap(responseData);

    if (envelope['success'] == false) {
      throw AppException(envelope['message'] as String? ?? 'İstek başarısız.');
    }

    final data = envelope['data'];
    return data is List ? data : const [];
  }

  static void unwrapVoid(dynamic responseData) {
    final envelope = _asMap(responseData);

    if (envelope['success'] == false) {
      throw AppException(envelope['message'] as String? ?? 'İstek başarısız.');
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }
}
