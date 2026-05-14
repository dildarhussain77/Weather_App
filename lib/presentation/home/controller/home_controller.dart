import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';
import 'package:weather_app1/domain/usecases/get_weather_by_coordinates_usecase.dart';
import 'package:weather_app1/presentation/home/controller/city_search_controller.dart';
import 'package:weather_app1/routes/app_routes.dart';

class HomeController extends GetxController {
  HomeController({
    required GetWeatherByCoordinatesUseCase getWeatherByCoordinates,
  }) : _getWeatherByCoordinates = getWeatherByCoordinates;

  final GetWeatherByCoordinatesUseCase _getWeatherByCoordinates;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<WeatherForecast> currentWeather = Rxn<WeatherForecast>();

  @override
  void onInit() {
    super.onInit();
    loadLocationWeather();
  }

  Future<void> loadLocationWeather() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Location permissions are permanently denied';
        isLoading.value = false;
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final WeatherForecast weather = await _getWeatherByCoordinates(
        position.latitude,
        position.longitude,
      );
      currentWeather.value = weather;
    } catch (e) {
      errorMessage.value = 'Failed to get location weather: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void openCitySearch() {
    if (Get.isRegistered<CitySearchController>()) {
      Get.delete<CitySearchController>(force: true);
    }
    Get.toNamed(AppRoutes.citySearch);
  }
}
