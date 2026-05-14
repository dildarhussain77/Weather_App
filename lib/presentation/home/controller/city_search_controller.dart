import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app1/core/constants/app_constants.dart';
import 'package:weather_app1/core/utils/debouncer.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';
import 'package:weather_app1/domain/usecases/get_city_suggestions_usecase.dart';
import 'package:weather_app1/domain/usecases/get_weather_by_city_usecase.dart';

class CitySearchController extends GetxController {
  CitySearchController({
    required GetCitySuggestionsUseCase getCitySuggestions,
    required GetWeatherByCityUseCase getWeatherByCity,
  })  : _getCitySuggestions = getCitySuggestions,
        _getWeatherByCity = getWeatherByCity;

  final GetCitySuggestionsUseCase _getCitySuggestions;
  final GetWeatherByCityUseCase _getWeatherByCity;

  final Debouncer _debouncer =
      Debouncer(duration: AppConstants.searchDebounce);

  late final TextEditingController textFieldController;

  final RxString query = ''.obs;
  final RxList<CitySuggestion> suggestions = <CitySuggestion>[].obs;
  final RxBool isLoading = false.obs;
  final Rxn<WeatherForecast> resultWeather = Rxn<WeatherForecast>();

  @override
  void onInit() {
    super.onInit();
    textFieldController = TextEditingController();
    textFieldController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    onQueryChanged(textFieldController.text);
  }

  @override
  void onClose() {
    textFieldController.removeListener(_onTextChanged);
    textFieldController.dispose();
    _debouncer.cancel();
    super.onClose();
  }

  void onQueryChanged(String text) {
    query.value = text;
    resultWeather.value = null;

    if (text.length < AppConstants.minCityQueryLength) {
      suggestions.clear();
      return;
    }

    _debouncer.run(() => _fetchSuggestions(text));
  }

  Future<void> _fetchSuggestions(String text) async {
    isLoading.value = true;
    try {
      final List<CitySuggestion> list = await _getCitySuggestions(text);
      final String lower = text.toLowerCase();
      suggestions.assignAll(
        list
            .where(
              (CitySuggestion c) =>
                  c.name.toLowerCase().contains(lower),
            )
            .toList(),
      );
    } catch (_) {
      suggestions.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectCity(String cityName) async {
    isLoading.value = true;
    suggestions.clear();
    try {
      final WeatherForecast w = await _getWeatherByCity(cityName);
      resultWeather.value = w;
    } catch (e) {
      resultWeather.value = null;
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void clearQuery() {
    textFieldController.clear();
    query.value = '';
    suggestions.clear();
    resultWeather.value = null;
  }
}
