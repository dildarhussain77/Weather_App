import 'package:dio/dio.dart';
import 'package:weather_app1/core/constants/api_endpoints.dart';
import 'package:weather_app1/core/constants/app_constants.dart';
import 'package:weather_app1/core/constants/app_env.dart';
import 'package:weather_app1/core/network/app_http_extras.dart';

/// Remote OpenWeatherMap calls (Dio only, no business rules).
class WeatherRemoteDataSource {
  WeatherRemoteDataSource(this._dio);

  final Dio _dio;

  /// Geocoding 1.0 — purpose-built city / place search (replaces v2.5 `/find`).
  Future<List<dynamic>> searchLocationsDirect(
    String query, {
    CancelToken? cancelToken,
  }) async {
    final Uri uri = Uri.https(
      AppEnv.openWeatherGeoHost,
      '/geo/1.0/direct',
      <String, String>{
        'q': query,
        'limit': '${AppConstants.citySearchGeoLimit}',
        'appid': AppEnv.openWeatherApiKey,
      },
    );
    final Response<dynamic> res = await _dio.getUri<dynamic>(
      uri,
      cancelToken: cancelToken,
      options: Options(
        extra: <String, dynamic>{
          AppHttpExtras.quietNetwork: true,
        },
      ),
    );
    final dynamic body = res.data;
    if (body is List<dynamic>) {
      return body;
    }
    return <dynamic>[];
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
