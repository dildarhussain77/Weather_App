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

  static List<CitySuggestion> citySuggestionsFromFindResponse(
    Map<String, dynamic> data,
  ) {
    final List<dynamic>? list = data['list'] as List?;
    if (list == null) {
      return <CitySuggestion>[];
    }

    final List<CitySuggestion> suggestions = list.map((dynamic city) {
      final Map<String, dynamic> c = Map<String, dynamic>.from(city as Map);
      final Map<String, dynamic> sys =
          Map<String, dynamic>.from(c['sys'] as Map? ?? {});
      final Map<String, dynamic> coord =
          Map<String, dynamic>.from(c['coord'] as Map? ?? {});
      return CitySuggestion(
        name: c['name']?.toString() ?? '',
        country: sys['country']?.toString() ?? '',
        lat: (coord['lat'] as num?)?.toDouble() ?? 0,
        lon: (coord['lon'] as num?)?.toDouble() ?? 0,
        population: (c['population'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    suggestions.sort((CitySuggestion a, CitySuggestion b) =>
        b.population.compareTo(a.population));
    return suggestions;
  }
}
