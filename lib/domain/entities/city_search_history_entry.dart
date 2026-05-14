/// Recent city selection for quick re-fetch (offline-friendly display + lat/lon).
class CitySearchHistoryEntry {
  const CitySearchHistoryEntry({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
    this.state,
  });

  final String name;
  final String country;
  final double lat;
  final double lon;
  final String? state;

  String get displayLabel {
    final List<String> parts = <String>[name];
    if (state != null && state!.trim().isNotEmpty) {
      parts.add(state!.trim());
    }
    if (country.trim().isNotEmpty) {
      parts.add(country.trim());
    }
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'country': country,
        'lat': lat,
        'lon': lon,
        if (state != null) 'state': state,
      };

  static CitySearchHistoryEntry? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    final String name = json['name']?.toString() ?? '';
    if (name.isEmpty) {
      return null;
    }
    return CitySearchHistoryEntry(
      name: name,
      country: json['country']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lon: (json['lon'] as num?)?.toDouble() ?? 0,
      state: json['state']?.toString(),
    );
  }
}
