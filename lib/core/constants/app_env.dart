/// Environment and third-party configuration.
abstract final class AppEnv {
  /// OpenWeatherMap API base (v2.5) — current weather, etc.
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5/';

  /// Geocoding API 1.0 (city / location search). Different path than v2.5.
  static const String openWeatherGeoHost = 'api.openweathermap.org';

  /// API key — replace via build flavors or secure storage in production.
  static const String openWeatherApiKey =
      'f8c15bd838a377ad995febd4cc97ccf3';
}
