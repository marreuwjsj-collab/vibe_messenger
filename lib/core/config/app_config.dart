enum AppEnvironment { development, staging, production }

final class AppConfig {
  final AppEnvironment environment;
  final String apiBaseUrl;
  final Duration networkTimeout;

  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.networkTimeout = const Duration(seconds: 20),
  });

  bool get isProduction => environment == AppEnvironment.production;

  static const development = AppConfig(
    environment: AppEnvironment.development,
    apiBaseUrl: 'http://localhost:8080',
  );
}
