import 'package:flutter/foundation.dart';

enum BackendMode { mock, api }

const _defaultApiPort = '4000';

class AppConfig {
  const AppConfig({required this.backendMode, required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() {
    const mode = String.fromEnvironment('MCG_BACKEND', defaultValue: 'api');
    const baseUrl = String.fromEnvironment('MCG_API_BASE_URL');
    const apiPort = String.fromEnvironment(
      'MCG_API_PORT',
      defaultValue: _defaultApiPort,
    );
    return AppConfig.fromEnvironmentValues(
      mode: mode,
      apiBaseUrl: baseUrl,
      apiPort: apiPort,
      isWeb: kIsWeb,
      targetPlatform: defaultTargetPlatform,
    );
  }

  @visibleForTesting
  factory AppConfig.fromEnvironmentValues({
    String mode = 'api',
    String apiBaseUrl = '',
    String apiPort = _defaultApiPort,
    bool isWeb = kIsWeb,
    TargetPlatform? targetPlatform,
  }) {
    final effectiveTargetPlatform = targetPlatform ?? defaultTargetPlatform;
    return AppConfig(
      backendMode: mode == 'api' ? BackendMode.api : BackendMode.mock,
      apiBaseUrl: _resolveApiBaseUrl(
        apiBaseUrl,
        apiPort: apiPort,
        isWeb: isWeb,
        targetPlatform: effectiveTargetPlatform,
      ),
    );
  }

  final BackendMode backendMode;
  final String apiBaseUrl;

  bool get useMockBackend => backendMode == BackendMode.mock;

  String? get validationError {
    if (backendMode == BackendMode.api && apiBaseUrl.trim().isEmpty) {
      return 'MCG_API_BASE_URL is required when MCG_BACKEND=api.';
    }
    return null;
  }
}

String _resolveApiBaseUrl(
  String configuredBaseUrl, {
  required String apiPort,
  required bool isWeb,
  required TargetPlatform targetPlatform,
}) {
  final baseUrl = configuredBaseUrl.trim().isEmpty
      ? _defaultApiBaseUrl(
          apiPort: apiPort,
          isWeb: isWeb,
          targetPlatform: targetPlatform,
        )
      : configuredBaseUrl.trim();

  if (targetPlatform == TargetPlatform.android) {
    return baseUrl;
  }

  final uri = Uri.tryParse(baseUrl);
  if (uri == null || uri.host != '10.0.2.2') {
    return baseUrl;
  }

  return uri.replace(host: '127.0.0.1').toString();
}

String _defaultApiBaseUrl({
  required String apiPort,
  required bool isWeb,
  required TargetPlatform targetPlatform,
}) {
  final host = !isWeb && targetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : '127.0.0.1';

  return Uri(
    scheme: 'http',
    host: host,
    port: _resolveApiPort(apiPort),
  ).toString();
}

int _resolveApiPort(String configuredPort) {
  final parsedPort = int.tryParse(configuredPort.trim());
  if (parsedPort == null || parsedPort <= 0 || parsedPort > 65535) {
    return int.parse(_defaultApiPort);
  }
  return parsedPort;
}
