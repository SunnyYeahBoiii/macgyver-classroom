enum BackendMode { mock, api }

class AppConfig {
  const AppConfig({required this.backendMode, required this.apiBaseUrl});

  factory AppConfig.fromEnvironment() {
    const mode = String.fromEnvironment('MCG_BACKEND', defaultValue: 'mock');
    const baseUrl = String.fromEnvironment('MCG_API_BASE_URL');
    return AppConfig(
      backendMode: mode == 'api' ? BackendMode.api : BackendMode.mock,
      apiBaseUrl: baseUrl,
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
