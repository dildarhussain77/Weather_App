import 'package:get/get.dart';
import 'package:weather_app1/presentation/home/view/city_search_view.dart';
import 'package:weather_app1/presentation/home/view/home_view.dart';
import 'package:weather_app1/presentation/splash/view/splash_view.dart';
import 'package:weather_app1/routes/app_routes.dart';

/// Central [GetMaterialApp] page graph.
abstract final class AppRouter {
  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const HomeView(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.citySearch,
      page: () => const CitySearchView(),
    ),
  ];
}
