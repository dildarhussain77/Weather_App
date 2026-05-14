import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app1/core/constants/app_constants.dart';
import 'package:weather_app1/core/utils/debouncer.dart';
import 'package:weather_app1/data/data_sources/local/local_prefs_service.dart';
import 'package:weather_app1/domain/entities/city_search_history_entry.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';
import 'package:weather_app1/core/utils/city_search_utils.dart';
import 'package:weather_app1/domain/usecases/get_city_suggestions_usecase.dart';
import 'package:weather_app1/domain/usecases/get_weather_by_coordinates_usecase.dart';

class CitySearchController extends GetxController {
  CitySearchController({
    required GetCitySuggestionsUseCase getCitySuggestions,
    required GetWeatherByCoordinatesUseCase getWeatherByCoordinates,
    required LocalPrefsService localPrefs,
  })  : _getCitySuggestions = getCitySuggestions,
        _getWeatherByCoordinates = getWeatherByCoordinates,
        _localPrefs = localPrefs;

  final GetCitySuggestionsUseCase _getCitySuggestions;
  final GetWeatherByCoordinatesUseCase _getWeatherByCoordinates;
  final LocalPrefsService _localPrefs;

  final Debouncer _debouncer =
      Debouncer(duration: AppConstants.searchDebounce);

  late final TextEditingController textFieldController;

  final RxString query = ''.obs;
  final RxList<CitySuggestion> suggestions = <CitySuggestion>[].obs;
  final RxList<CitySearchHistoryEntry> historyEntries =
      <CitySearchHistoryEntry>[].obs;

  final RxBool loadingSuggestions = false.obs;
  final RxBool loadingWeather = false.obs;
  final RxnString suggestionsError = RxnString();

  int _suggestionRequestId = 0;
  CancelToken? _suggestionCancel;

  final Rxn<WeatherForecast> resultWeather = Rxn<WeatherForecast>();

  @override
  void onInit() {
    super.onInit();
    textFieldController = TextEditingController();
    textFieldController.addListener(_onTextChanged);
    historyEntries.assignAll(_localPrefs.getCitySearchHistory());
  }

  void _onTextChanged() {
    onQueryChanged(textFieldController.text);
  }

  @override
  void onClose() {
    textFieldController.removeListener(_onTextChanged);
    textFieldController.dispose();
    _suggestionCancel?.cancel();
    _debouncer.cancel();
    super.onClose();
  }

  void onQueryChanged(String text) {
    query.value = text;
    resultWeather.value = null;
    suggestionsError.value = null;

    final String norm = SearchQueryNormalizer.normalize(text);
    if (norm.length < AppConstants.minCityQueryLength) {
      _suggestionCancel?.cancel();
      suggestions.clear();
      loadingSuggestions.value = false;
      return;
    }

    _debouncer.run(() => _fetchSuggestions(norm));
  }

  Future<void> retrySuggestions() {
    return _fetchSuggestions(
      SearchQueryNormalizer.normalize(textFieldController.text),
    );
  }

  Future<void> _fetchSuggestions(String normalizedQuery) async {
    if (normalizedQuery.length < AppConstants.minCityQueryLength) {
      suggestions.clear();
      loadingSuggestions.value = false;
      return;
    }

    final int reqId = ++_suggestionRequestId;
    _suggestionCancel?.cancel();
    _suggestionCancel = CancelToken();
    final CancelToken token = _suggestionCancel!;

    loadingSuggestions.value = true;
    suggestionsError.value = null;
    try {
      final List<CitySuggestion> list = await _getCitySuggestions(
        normalizedQuery,
        cancelToken: token,
      );
      if (reqId != _suggestionRequestId) {
        return;
      }
      suggestions.assignAll(
        CitySuggestionRanker.sort(list, normalizedQuery),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return;
      }
      if (reqId != _suggestionRequestId) {
        return;
      }
      suggestions.clear();
      suggestionsError.value = _userMessageForDio(e);
    } catch (e) {
      if (reqId != _suggestionRequestId) {
        return;
      }
      suggestions.clear();
      suggestionsError.value = e.toString();
    } finally {
      if (reqId == _suggestionRequestId) {
        loadingSuggestions.value = false;
      }
    }
  }

  String _userMessageForDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Check your connection and try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Showing history only until you are back online.';
      case DioExceptionType.badResponse:
        return 'Search service returned an error. Pull to retry or try again later.';
      default:
        return e.message ?? 'Search failed. Please try again.';
    }
  }

  Future<void> selectSuggestion(CitySuggestion s) async {
    loadingWeather.value = true;
    suggestionsError.value = null;
    try {
      final WeatherForecast w =
          await _getWeatherByCoordinates(s.lat, s.lon);
      resultWeather.value = w;
      await _recordHistory(
        CitySearchHistoryEntry(
          name: s.name,
          country: s.country,
          lat: s.lat,
          lon: s.lon,
          state: s.state,
        ),
      );
    } catch (e) {
      resultWeather.value = null;
      Get.snackbar('Error', e.toString());
    } finally {
      loadingWeather.value = false;
    }
  }

  Future<void> selectHistoryEntry(CitySearchHistoryEntry e) async {
    loadingWeather.value = true;
    try {
      final WeatherForecast w =
          await _getWeatherByCoordinates(e.lat, e.lon);
      resultWeather.value = w;
      await _recordHistory(e);
    } catch (err) {
      resultWeather.value = null;
      Get.snackbar('Error', err.toString());
    } finally {
      loadingWeather.value = false;
    }
  }

  Future<void> _recordHistory(CitySearchHistoryEntry entry) async {
    final List<CitySearchHistoryEntry> next = <CitySearchHistoryEntry>[
      entry,
      ...historyEntries.where(
        (CitySearchHistoryEntry x) =>
            (x.lat - entry.lat).abs() > 1e-4 ||
            (x.lon - entry.lon).abs() > 1e-4,
      ),
    ].take(AppConstants.citySearchHistoryMax).toList();

    historyEntries.assignAll(next);
    await _localPrefs.setCitySearchHistory(next);
  }

  void clearQuery() {
    _suggestionCancel?.cancel();
    textFieldController.clear();
    query.value = '';
    suggestions.clear();
    resultWeather.value = null;
    suggestionsError.value = null;
    loadingSuggestions.value = false;
  }
}
