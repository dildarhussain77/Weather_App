import 'package:dio/dio.dart';

/// Domain contracts + entities for weather feature.
class CitySuggestion {
  const CitySuggestion({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    required this.population,
    this.state,
  });

  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;

  /// OpenWeather "find" had population; geo API does not — keep for sorting compat.
  final int population;

  /// Lowercased concatenation for relevance ranking (not for strict filtering).
  String get searchHaystack {
    final List<String> parts = <String>[name];
    if (state != null && state!.trim().isNotEmpty) {
      parts.add(state!.trim());
    }
    parts.add(country);
    return parts.join(' ');
  }

  String get subtitleLine {
    final List<String> parts = <String>[];
    if (state != null && state!.trim().isNotEmpty) {
      parts.add(state!.trim());
    }
    if (country.isNotEmpty) {
      parts.add(country);
    }
    return parts.join(', ');
  }
}

class WeatherForecast {
  const WeatherForecast({
    required this.cityName,
    required this.countryCode,
    required this.tempC,
    required this.description,
    required this.weatherMain,
    required this.humidity,
    required this.windSpeed,
  });

  final String cityName;
  final String countryCode;
  final double tempC;
  final String description;
  final String weatherMain;
  final int humidity;
  final double windSpeed;
}

abstract class IWeatherRepository {
  /// Location search via OpenWeather Geocoding 1.0 (not v2.5 `/find`).
  Future<List<CitySuggestion>> getCitySuggestions(
    String query, {
    CancelToken? cancelToken,
  });

  Future<WeatherForecast> getWeatherByCity(String city);

  Future<WeatherForecast> getWeatherByCoordinates(double lat, double lon);
}
