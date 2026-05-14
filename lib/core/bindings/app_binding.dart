import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app1/core/network/app_api_loading_controller.dart';
import 'package:weather_app1/data/data_sources/remote/app_http_client.dart';
import 'package:weather_app1/core/session/session_controller.dart';
import 'package:weather_app1/data/data_sources/local/local_prefs_service.dart';
import 'package:weather_app1/data/data_sources/remote/weather_remote_data_source.dart';
import 'package:weather_app1/data/repo_impl/weather_repository_impl.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';
import 'package:weather_app1/domain/usecases/get_city_suggestions_usecase.dart';
import 'package:weather_app1/domain/usecases/get_weather_by_city_usecase.dart';
import 'package:weather_app1/domain/usecases/get_weather_by_coordinates_usecase.dart';
import 'package:weather_app1/presentation/home/controller/city_search_controller.dart';
import 'package:weather_app1/presentation/home/controller/home_controller.dart';

/// Global dependency registration (Dio, repositories, use cases, controllers).
class AppBinding extends Bindings {
  AppBinding(this._preferences);

  final SharedPreferences _preferences;

  @override
  void dependencies() {
    Get.put<LocalPrefsService>(LocalPrefsService(_preferences), permanent: true);

    Get.put<AppApiLoadingController>(
      AppApiLoadingController(),
      permanent: true,
    );

    Get.put<AppHttpClient>(AppHttpClient(), permanent: true);
    Get.put<WeatherRemoteDataSource>(
      WeatherRemoteDataSource(Get.find<AppHttpClient>().dio),
      permanent: true,
    );
    Get.put<IWeatherRepository>(
      WeatherRepositoryImpl(Get.find<WeatherRemoteDataSource>()),
      permanent: true,
    );

    Get.put<GetCitySuggestionsUseCase>(
      GetCitySuggestionsUseCase(Get.find<IWeatherRepository>()),
      permanent: true,
    );
    Get.put<GetWeatherByCityUseCase>(
      GetWeatherByCityUseCase(Get.find<IWeatherRepository>()),
      permanent: true,
    );
    Get.put<GetWeatherByCoordinatesUseCase>(
      GetWeatherByCoordinatesUseCase(Get.find<IWeatherRepository>()),
      permanent: true,
    );

    Get.put<SessionController>(SessionController(), permanent: true);

    Get.put<HomeController>(
      HomeController(
        getWeatherByCoordinates: Get.find<GetWeatherByCoordinatesUseCase>(),
      ),
      permanent: true,
    );

    Get.lazyPut<CitySearchController>(
      () => CitySearchController(
        getCitySuggestions: Get.find<GetCitySuggestionsUseCase>(),
        getWeatherByCoordinates:
            Get.find<GetWeatherByCoordinatesUseCase>(),
        localPrefs: Get.find<LocalPrefsService>(),
      ),
      fenix: true,
    );
  }
}
