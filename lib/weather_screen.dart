import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app1/weather_search.dart';
import 'package:weather_app1/weather_services.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Position? _currentPosition;
  Map<String, dynamic>? _currentWeather;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocationWeather();
  }

  Future<void> _getCurrentLocationWeather() async {
    try {
      // Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied';
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Fetch weather for current location
      final weather = await _weatherService.getWeatherByCoordinates(
        position.latitude, 
        position.longitude
      );

      setState(() {
        _currentWeather = weather;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to get location weather: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weather Forecast',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 30,
                        ),
                        onPressed: () {
                          showSearch(
                            context: context,
                            delegate: WeatherSearchDelegate(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
      
                // Current Location Weather or Loading/Error State
                Expanded(
                  child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : _errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 100,
                                color: Colors.white,
                              ),
                              SizedBox(height: 20),
                              Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _getCurrentLocationWeather,
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _currentWeather != null
                        ? _buildCurrentLocationWeather()
                        : Center(
                            child: Text(
                              'Unable to fetch weather',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLocationWeather() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          _getWeatherIcon(_currentWeather!['weather'][0]['main']),
          size: 120,
          color: Colors.white,
        ),
        SizedBox(height: 20),
        Text(
          '${_currentWeather!['name']}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '${_currentWeather!['main']['temp'].toStringAsFixed(1)}°C',
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w300,
          ),
        ),
        SizedBox(height: 10),
        Text(
          '${_currentWeather!['weather'][0]['description']}',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            showSearch(
              context: context,
              delegate: WeatherSearchDelegate(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
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

  // Helper method to get weather icon based on weather condition
  IconData _getWeatherIcon(String weatherMain) {
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
