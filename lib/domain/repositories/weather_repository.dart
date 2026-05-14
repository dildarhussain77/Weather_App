/// Domain contracts + entities for weather feature.
class CitySuggestion {
  const CitySuggestion({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    required this.population,
  });

  final String name;
  final String country;
  final double lat;
  final double lon;
  final int population;
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
  Future<List<CitySuggestion>> getCitySuggestions(String query);

  Future<WeatherForecast> getWeatherByCity(String city);

  Future<WeatherForecast> getWeatherByCoordinates(double lat, double lon);
}
