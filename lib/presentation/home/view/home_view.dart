import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';
import 'package:weather_app1/presentation/home/controller/home_controller.dart';
import 'package:weather_app1/presentation/home/widgets/weather_condition_icon.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.blue.shade300,
                Colors.blue.shade700,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Weather Forecast',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: controller.openCitySearch,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      );
                    }
                    if (controller.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Icon(
                              Icons.error_outline,
                              size: 100,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              controller.errorMessage.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: controller.loadLocationWeather,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    final WeatherForecast? w = controller.currentWeather.value;
                    if (w != null) {
                      return _HomeWeatherBody(
                        forecast: w,
                        onSearchTap: controller.openCitySearch,
                      );
                    }
                    return const Center(
                      child: Text(
                        'Unable to fetch weather',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeWeatherBody extends StatelessWidget {
  const _HomeWeatherBody({
    required this.forecast,
    required this.onSearchTap,
  });

  final WeatherForecast forecast;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          WeatherConditionIcon.forMain(forecast.weatherMain),
          size: 120,
          color: Colors.white,
        ),
        const SizedBox(height: 20),
        Text(
          forecast.cityName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '${forecast.tempC.toStringAsFixed(1)}°C',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          forecast.description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: onSearchTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            'Search Cities',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
