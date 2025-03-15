import 'dart:async';
import 'package:flutter/material.dart';
import 'package:weather_app1/weather_services.dart';

class WeatherSearchDelegate extends SearchDelegate {

  final WeatherService weatherService = WeatherService();
  List<dynamic> citySuggestions = [];
  bool isLoading = false;
  final debounceDuration = Duration(milliseconds: 500);
  Timer? _debounceTimer;


  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white54),
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }

  // Existing _getCitySuggestions method remains the same as in previous implementation

  void _getCitySuggestions(String query) {
    _debounceTimer?.cancel();

    if (query.length >= 2) {
      _debounceTimer = Timer(debounceDuration, () async {
        setState(() {
          isLoading = true;
        });

        try {
          var suggestions = await weatherService.getCitySuggestions(query);
          
          var filteredSuggestions = suggestions.where((city) => 
            city['name'].toString().toLowerCase().contains(query.toLowerCase())
          ).toList();

          setState(() {
            citySuggestions = filteredSuggestions;
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
            citySuggestions = [];
          });
          print('Error fetching suggestions: $e');
        }
      });
    } else {
      setState(() {
        citySuggestions = [];
      });
    }
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      SafeArea(
        child: IconButton(
          icon: Icon(Icons.clear, color: Colors.white),
          onPressed: () {
            query = '';
            citySuggestions.clear();
            showSuggestions(context);
          },
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return SafeArea(
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          close(context, null);
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade300,
                Colors.blue.shade700,
              ],
            ),
          ),
          child: FutureBuilder(
            future: weatherService.getWeather(query),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                );
              }
        
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
        
              var weatherData = snapshot.data;
              if (weatherData != null && weatherData['cod'] == 200) {
                return _buildWeatherResultCard(weatherData);
              }
        
              return Center(
                child: Text(
                  'City not found.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Detailed weather result card
  Widget _buildWeatherResultCard(Map<String, dynamic> weatherData) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade700,
                ],
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${weatherData['name']}, ${weatherData['sys']['country']}',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${weatherData['main']['temp'].toStringAsFixed(1)}°C',
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '${weatherData['weather'][0]['description']}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildWeatherDetail(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '${weatherData['main']['humidity']}%',
                    ),
                    _buildWeatherDetail(
                      icon: Icons.air,
                      label: 'Wind',
                      value: '${weatherData['wind']['speed']} m/s',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for weather details
  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Trigger suggestions when query changes
    if (query.isNotEmpty && citySuggestions.isEmpty) {
      _getCitySuggestions(query);
    }

    // Container with gradient background
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade300,
                Colors.blue.shade700,
              ],
            ),
          ),
          child: Column(
            children: [
              // Loading indicator
              if (isLoading)
                LinearProgressIndicator(
                  backgroundColor: Colors.blue.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
        
              // Suggestions list
              Expanded(
                child: _buildSuggestionsList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Separated suggestion list builder
  Widget _buildSuggestionsList(BuildContext context) {
    // Show loading spinner while fetching suggestions
    if (isLoading) {
      
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    // If suggestions are available, display them
    if (citySuggestions.isNotEmpty) {
      return ListView.builder(
        itemCount: citySuggestions.length,
        itemBuilder: (context, index) {
          String cityName = citySuggestions[index]['name'];
          String country = citySuggestions[index]['country'];
          return ListTile(
            title: Text(
              cityName,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              country,
              style: TextStyle(color: Colors.white70),
            ),
            leading: Icon(Icons.location_city, color: Colors.white),
            onTap: () {
              query = cityName; // Set the query to the selected city
              showResults(context); // Show results for the selected city
            }
          );
        }
      );
    }      

    // If no suggestions found, show a message
    return Center(
      child: Text(
        query.isEmpty 
          ? 'Please enter a city name' 
          : 'No cities found matching "$query"',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  void setState(VoidCallback fn) {
    fn();
  }
}