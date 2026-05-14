import 'package:dio/dio.dart';
import 'package:weather_app1/data/data_sources/remote/weather_remote_data_source.dart';
import 'package:weather_app1/data/models/weather_mapper.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements IWeatherRepository {
  WeatherRepositoryImpl(this._remote);

  final WeatherRemoteDataSource _remote;

  void _assertWeatherOk(Map<String, dynamic> data) {
    final dynamic c = data['cod'];
    if (c == null) {
      return;
    }
    if (c is int && c != 200) {
      throw Exception('City not found.');
    }
    if (c is String && c != '200') {
      throw Exception('City not found.');
    }
  }

  @override
  Future<List<CitySuggestion>> getCitySuggestions(String query) async {
    try {
      final Map<String, dynamic> data = await _remote.findCities(query);
      return WeatherMapper.citySuggestionsFromFindResponse(data);
    } on DioException catch (e) {
      throw Exception('Failed to load city suggestions: ${e.message}');
    }
  }

  @override
  Future<WeatherForecast> getWeatherByCity(String city) async {
    try {
      final Map<String, dynamic> data = await _remote.getWeatherByCity(city);
      _assertWeatherOk(data);
      return WeatherMapper.fromCurrentWeatherJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to load weather data: ${e.message}');
    }
  }

  @override
  Future<WeatherForecast> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    try {
      final Map<String, dynamic> data =
          await _remote.getWeatherByCoordinates(lat, lon);
      _assertWeatherOk(data);
      return WeatherMapper.fromCurrentWeatherJson(data);
    } on DioException catch (e) {
      throw Exception('Failed to load weather data by coordinates: ${e.message}');
    }
  }
}
