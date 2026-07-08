import 'package:flutter_test/flutter_test.dart';
import 'package:mind_space/src/core/config/app_config.dart';

void main() {
  test('MindSpace API configuration is defined', () {
    expect(AppConfig.appName, 'MindSpace');
    expect(AppConfig.apiDocumentRootPath, r'C:\xampp\htdocs\MindSpace');
    expect(AppConfig.localApiBaseUrl, 'http://localhost/MindSpace');
    expect(AppConfig.localNetworkApiBaseUrl, 'http://192.168.0.102/MindSpace');
    expect(AppConfig.androidEmulatorApiBaseUrl, 'http://10.0.2.2/MindSpace');
  });
}
