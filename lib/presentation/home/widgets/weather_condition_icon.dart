import 'package:flutter/material.dart';

/// Maps OpenWeather `main` condition to Material icons.
abstract final class WeatherConditionIcon {
  static IconData forMain(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.water;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.snowing;
      default:
        return Icons.wb_cloudy;
    }
  }
}
