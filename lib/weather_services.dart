import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String apiKey = 'f8c15bd838a377ad995febd4cc97ccf3';  // Replace with your OpenWeatherMap API key

  // Method to get city suggestions with improved search capabilities
  Future<List<dynamic>> getCitySuggestions(String query) async {
    try {
      // Use the more comprehensive geo API for city suggestions
      final response = await http.get(
        Uri.parse('$_baseUrl/find?q=$query&type=like&sort=population&cnt=10&appid=$apiKey&units=metric')
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        // Check if the response contains a list of cities
        if (data != null && data['list'] != null) {
          // Map and filter the suggestions
          List<dynamic> suggestions = data['list'].map((city) {
            return {
              'name': city['name'] ?? '',
              'country': city['sys']['country'] ?? '',
              'lat': city['coord']['lat'] ?? 0.0,
              'lon': city['coord']['lon'] ?? 0.0,
              'population': city['population'] ?? 0
            };
          }).toList();

          // Sort suggestions by population (most populous first)
          suggestions.sort((a, b) => b['population'].compareTo(a['population']));

          return suggestions;
        }
        
        return []; // Return empty list if no suggestions found
      } else {
        // Print error details for debugging
        print('API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load city suggestions');
      }
    } catch (e) {
      print('Error in getCitySuggestions: $e');
      rethrow;
    }
  }

  // Method to get weather data for a specific city
  Future<Map<String, dynamic>> getWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?q=$city&appid=$apiKey&units=metric')
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Weather API Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error in getWeather: $e');
      rethrow;
    }
  }

  // Optional: Add a method to get weather by coordinates for more precise results
  Future<Map<String, dynamic>> getWeatherByCoordinates(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric')
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load weather data by coordinates');
      }
    } catch (e) {
      print('Error in getWeatherByCoordinates: $e');
      rethrow;
    }
  }
}