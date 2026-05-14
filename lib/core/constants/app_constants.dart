/// App-wide non-secret constants.
abstract final class AppConstants {
  static const String appName = 'Weather App';
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const int minCityQueryLength = 2;
}
