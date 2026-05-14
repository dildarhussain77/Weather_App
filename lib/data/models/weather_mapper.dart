import 'package:weather_app1/domain/repositories/weather_repository.dart';

/// Maps OpenWeatherMap JSON to domain models.
class WeatherMapper {
  static WeatherForecast fromCurrentWeatherJson(Map<String, dynamic> json) {
    final Map<String, dynamic> main =
        Map<String, dynamic>.from(json['main'] as Map? ?? {});
    final List<dynamic> weatherList = json['weather'] as List? ?? [];
    final Map<String, dynamic> weather0 =
        Map<String, dynamic>.from(weatherList.first as Map? ?? {});
    final Map<String, dynamic> wind =
        Map<String, dynamic>.from(json['wind'] as Map? ?? {});
    final Map<String, dynamic> sys =
        Map<String, dynamic>.from(json['sys'] as Map? ?? {});

    return WeatherForecast(
      cityName: json['name']?.toString() ?? '',
      countryCode: sys['country']?.toString() ?? '',
      tempC: (main['temp'] as num?)?.toDouble() ?? 0,
      description: weather0['description']?.toString() ?? '',
      weatherMain: weather0['main']?.toString() ?? '',
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Parses [Geo 1.0 Direct](https://openweathermap.org/api/geocoding-api) JSON array.
  static List<CitySuggestion> citySuggestionsFromGeoDirectList(
    List<dynamic> raw,
  ) {
    final Map<String, CitySuggestion> deduped = <String, CitySuggestion>{};
    for (final dynamic item in raw) {
      if (item is! Map) {
        continue;
      }
      final CitySuggestion c = _citySuggestionFromGeoItem(
        Map<String, dynamic>.from(item),
      );
      if (c.name.isEmpty) {
        continue;
      }
      final String key =
          '${c.lat.toStringAsFixed(4)}_${c.lon.toStringAsFixed(4)}';
      deduped.putIfAbsent(key, () => c);
    }
    return deduped.values.toList();
  }

  static CitySuggestion _citySuggestionFromGeoItem(Map<String, dynamic> j) {
    return CitySuggestion(
      name: j['name']?.toString() ?? '',
      country: j['country']?.toString() ?? '',
      lat: (j['lat'] as num?)?.toDouble() ?? 0,
      lon: (j['lon'] as num?)?.toDouble() ?? 0,
      population: 0,
      state: j['state']?.toString(),
    );
  }
}
