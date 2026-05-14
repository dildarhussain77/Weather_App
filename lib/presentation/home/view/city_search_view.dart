import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:weather_app1/core/constants/app_constants.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';
import 'package:weather_app1/core/utils/city_search_utils.dart';
import 'package:weather_app1/presentation/home/controller/city_search_controller.dart';
import 'package:weather_app1/presentation/home/widgets/city_suggestion_tile.dart';
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
            textInputAction: TextInputAction.search,
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
            final WeatherForecast? result = controller.resultWeather.value;
            if (result != null) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  SingleChildScrollView(
                    child: WeatherResultCard(forecast: result),
                  ),
                  if (controller.loadingWeather.value)
                    ColoredBox(
                      color: Colors.black26,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                    ),
                ],
              );
            }

            return Obx(() {
              controller.historyEntries.length;
              controller.suggestionsError.value;
              controller.loadingSuggestions.value;
              controller.suggestions.length;
              controller.query.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _HistoryStrip(controller: controller),
                  _ErrorBanner(controller: controller),
                  if (controller.loadingSuggestions.value)
                    LinearProgressIndicator(
                      backgroundColor: Colors.blue.shade300,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  Expanded(
                    child: _SuggestionArea(controller: controller),
                  ),
                ],
              );
            });
          }),
        ),
      ),
    );
  }
}

class _HistoryStrip extends StatelessWidget {
  const _HistoryStrip({required this.controller});

  final CitySearchController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.historyEntries.isEmpty) {
      return const SizedBox.shrink();
    }
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: controller.historyEntries.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (BuildContext context, int i) {
            final entry = controller.historyEntries[i];
            return ActionChip(
              backgroundColor: Colors.white24,
              label: Text(
                entry.displayLabel,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 13),
              ),
              onPressed: () => controller.selectHistoryEntry(entry),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.controller});

  final CitySearchController controller;

  @override
  Widget build(BuildContext context) {
    final String? err = controller.suggestionsError.value;
    if (err == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.red.shade900.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: <Widget>[
              const Icon(Icons.error_outline, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  err,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
              TextButton(
                onPressed: controller.retrySuggestions,
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuggestionArea extends StatelessWidget {
  const _SuggestionArea({required this.controller});

  final CitySearchController controller;

  @override
  Widget build(BuildContext context) {
    final String q = controller.query.value;
    final String norm = SearchQueryNormalizer.normalize(q);

    if (norm.length < AppConstants.minCityQueryLength) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            controller.historyEntries.isEmpty
                ? 'Enter at least ${AppConstants.minCityQueryLength} characters to search, or pick a recent city above.'
                : 'Enter at least ${AppConstants.minCityQueryLength} characters to search.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ),
      );
    }

    if (controller.loadingSuggestions.value && controller.suggestions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (controller.suggestions.isNotEmpty) {
      return ListView.separated(
        itemCount: controller.suggestions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        itemBuilder: (BuildContext context, int index) {
          final CitySuggestion city = controller.suggestions[index];
          return CitySuggestionTile(
            suggestion: city,
            onTap: () => controller.selectSuggestion(city),
          );
        },
      );
    }

    return Center(
      child: Text(
        controller.suggestionsError.value != null
            ? 'Could not load suggestions.'
            : 'No cities found matching "$q".',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}
