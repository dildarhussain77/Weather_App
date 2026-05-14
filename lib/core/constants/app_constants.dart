/// App-wide non-secret constants.
abstract final class AppConstants {
  static const String appName = 'Weather App';
  static const Duration searchDebounce = Duration(milliseconds: 350);
  static const int minCityQueryLength = 2;

  /// OpenWeather Geocoding `limit` (API allows 1–5).
  static const int citySearchGeoLimit = 5;

  /// In-memory suggestion cache TTL.
  static const Duration citySearchCacheTtl = Duration(minutes: 10);

  static const int citySearchHistoryMax = 10;
}
