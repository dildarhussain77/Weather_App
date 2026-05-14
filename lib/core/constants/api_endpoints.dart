/// Relative paths for the OpenWeather **v2.5** Dio base URL (`AppHttpClient`).
/// City search uses **Geocoding 1.0** (`/geo/1.0/direct`) via absolute URI, not these paths.
abstract final class ApiEndpoints {
  static const String weather = 'weather';
}
