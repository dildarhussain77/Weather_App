import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';
import 'package:weather_app1/presentation/home/controller/city_search_controller.dart';
import 'package:weather_app1/presentation/home/widgets/weather_result_card.dart';

class CitySearchView extends GetView<CitySearchController> {
  const CitySearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade700,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: Get.back,
          ),
          title: TextField(
            controller: controller.textFieldController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search city',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: controller.clearQuery,
            ),
          ],
        ),
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
          child: Obx(() {
            final bool loading = controller.isLoading.value;
            final WeatherForecast? result = controller.resultWeather.value;

            if (loading &&
                controller.suggestions.isEmpty &&
                result == null &&
                controller.query.value.length >= 2) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (result != null) {
              return SingleChildScrollView(
                child: WeatherResultCard(forecast: result),
              );
            }

            return Column(
              children: <Widget>[
                if (loading)
                  LinearProgressIndicator(
                    backgroundColor: Colors.blue.shade300,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                const Expanded(child: _CitySuggestionsList()),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CitySuggestionsList extends GetView<CitySearchController> {
  const _CitySuggestionsList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final CitySearchController c = controller;
      if (c.isLoading.value && c.suggestions.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        );
      }

      if (c.suggestions.isNotEmpty) {
        return ListView.builder(
          itemCount: c.suggestions.length,
          itemBuilder: (BuildContext context, int index) {
            final CitySuggestion city = c.suggestions[index];
            return ListTile(
              title: Text(
                city.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                city.country,
                style: const TextStyle(color: Colors.white70),
              ),
              leading: const Icon(Icons.location_city, color: Colors.white),
              onTap: () => c.selectCity(city.name),
            );
          },
        );
      }

      final String q = c.query.value;
      return Center(
        child: Text(
          q.isEmpty
              ? 'Please enter a city name'
              : 'No cities found matching "$q"',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    });
  }
}
