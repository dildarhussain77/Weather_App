import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app1/core/bindings/app_binding.dart';
import 'package:weather_app1/core/constants/app_constants.dart';
import 'package:weather_app1/core/network/app_api_loading_overlay.dart';
import 'package:weather_app1/core/theme/app_theme.dart';
import 'package:weather_app1/routes/app_router.dart';
import 'package:weather_app1/routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  runApp(WeatherApp(preferences: preferences));
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key, required this.preferences});

  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      initialBinding: AppBinding(preferences),
      getPages: AppRouter.pages,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            if (child != null) child,
            const AppApiLoadingOverlay(),
          ],
        );
      },
    );
  }
}
