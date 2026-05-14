import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:weather_app1/core/constants/app_constants.dart';
import 'package:weather_app1/data/data_sources/remote/weather_remote_data_source.dart';
import 'package:weather_app1/data/models/weather_mapper.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';
import 'package:weather_app1/core/utils/city_search_utils.dart';

class _SuggestionCacheEntry {
  _SuggestionCacheEntry(this.items, this.storedAt);

  final List<CitySuggestion> items;
  final DateTime storedAt;
}

class WeatherRepositoryImpl implements IWeatherRepository {
  WeatherRepositoryImpl(this._remote);

  final WeatherRemoteDataSource _remote;

  static const int _maxCacheEntries = 40;

  final LinkedHashMap<String, _SuggestionCacheEntry> _suggestionCache =
      LinkedHashMap<String, _SuggestionCacheEntry>();

  void _touchSuggestionCache(String key, _SuggestionCacheEntry entry) {
    _suggestionCache.remove(key);
    _suggestionCache[key] = entry;
    while (_suggestionCache.length > _maxCacheEntries) {
      _suggestionCache.remove(_suggestionCache.keys.first);
    }
  }

  void _rememberSuggestions(String key, List<CitySuggestion> items) {
    _touchSuggestionCache(key, _SuggestionCacheEntry(items, DateTime.now()));
  }

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
  Future<List<CitySuggestion>> getCitySuggestions(
    String query, {
    CancelToken? cancelToken,
  }) async {
    final String key = SearchQueryNormalizer.normalize(query);
    if (key.length < AppConstants.minCityQueryLength) {
      return <CitySuggestion>[];
    }

    final _SuggestionCacheEntry? hit = _suggestionCache[key];
    if (hit != null &&
        DateTime.now().difference(hit.storedAt) <
            AppConstants.citySearchCacheTtl) {
      _touchSuggestionCache(key, hit);
      return List<CitySuggestion>.from(hit.items);
    }

    try {
      final List<dynamic> raw =
          await _remote.searchLocationsDirect(key, cancelToken: cancelToken);
      final List<CitySuggestion> list =
          WeatherMapper.citySuggestionsFromGeoDirectList(raw);
      _rememberSuggestions(key, list);
      return list;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
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
      throw Exception(
        'Failed to load weather data by coordinates: ${e.message}',
      );
    }
  }
}
