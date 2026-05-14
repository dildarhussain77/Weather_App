import 'package:flutter/material.dart';
import 'package:weather_app1/domain/repositories/weather_repository.dart';

class CitySuggestionTile extends StatelessWidget {
  const CitySuggestionTile({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  final CitySuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        suggestion.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        suggestion.subtitleLine,
        style: const TextStyle(color: Colors.white70),
      ),
      leading: const Icon(Icons.location_city, color: Colors.white),
      onTap: onTap,
    );
  }
}
