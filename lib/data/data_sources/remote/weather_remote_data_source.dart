import 'package:dio/dio.dart';
import 'package:weather_app1/core/constants/api_endpoints.dart';
import 'package:weather_app1/core/constants/app_env.dart';

/// Remote OpenWeatherMap calls (Dio only, no business rules).
class WeatherRemoteDataSource {
  WeatherRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> findCities(String query) async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.find,
      queryParameters: <String, dynamic>{
        'q': query,
        'type': 'like',
        'sort': 'population',
        'cnt': 10,
        'appid': AppEnv.openWeatherApiKey,
        'units': 'metric',
      },
    );
    return Map<String, dynamic>.from(res.data! as Map);
  }

  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weather,
      queryParameters: <String, dynamic>{
        'q': city,
        'appid': AppEnv.openWeatherApiKey,
        'units': 'metric',
      },
    );
    return Map<String, dynamic>.from(res.data! as Map);
  }

  Future<Map<String, dynamic>> getWeatherByCoordinates(
    double lat,
    double lon,
  ) async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.weather,
      queryParameters: <String, dynamic>{
        'lat': lat,
        'lon': lon,
        'appid': AppEnv.openWeatherApiKey,
        'units': 'metric',
      },
    );
    return Map<String, dynamic>.from(res.data! as Map);
  }
}
