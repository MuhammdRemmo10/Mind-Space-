import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const String appName = 'MindSpace';
  static const String apiDocumentRootPath = r'C:\xampp\htdocs\MindSpace';

  static const String localApiBaseUrl = 'http://localhost/MindSpace';
  static const String localNetworkApiBaseUrl = 'http://192.168.0.102/MindSpace';
  static const String androidEmulatorApiBaseUrl = 'http://10.0.2.2/MindSpace';
  static String get defaultApiBaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return localNetworkApiBaseUrl;
    }

    return localApiBaseUrl;
  }

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
