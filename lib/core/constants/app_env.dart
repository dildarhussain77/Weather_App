/// Environment and third-party configuration.
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppEnv {
  static String get openWeatherBaseUrl =>
      dotenv.env['OPEN_WEATHER_BASE_URL'] ?? '';

  static String get openWeatherApiKey =>
      dotenv.env['OPEN_WEATHER_API_KEY'] ?? '';

  static const String openWeatherGeoHost =
      'api.openweathermap.org';
}