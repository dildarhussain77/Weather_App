import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app1/data/data_sources/local/storage_keys.dart';
import 'package:weather_app1/domain/entities/city_search_history_entry.dart';

export 'storage_keys.dart';

/// Thin wrapper over [SharedPreferences].
class LocalPrefsService {
  LocalPrefsService(this._prefs);

  final SharedPreferences _prefs;

  String? get lastCity => getString(StorageKeys.lastCity);

  Future<void> setLastCity(String city) =>
      setString(StorageKeys.lastCity, city);

  List<CitySearchHistoryEntry> getCitySearchHistory() {
    final String? raw = _prefs.getString(StorageKeys.citySearchHistory);
    if (raw == null || raw.isEmpty) {
      return <CitySearchHistoryEntry>[];
    }
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((dynamic e) {
            if (e is Map<String, dynamic>) {
              return CitySearchHistoryEntry.fromJson(e);
            }
            if (e is Map) {
              return CitySearchHistoryEntry.fromJson(
                Map<String, dynamic>.from(e),
              );
            }
            return null;
          })
          .whereType<CitySearchHistoryEntry>()
          .toList();
    } catch (_) {
      return <CitySearchHistoryEntry>[];
    }
  }

  Future<void> setCitySearchHistory(List<CitySearchHistoryEntry> entries) {
    final String encoded =
        jsonEncode(entries.map((CitySearchHistoryEntry e) => e.toJson()).toList());
    return setString(StorageKeys.citySearchHistory, encoded);
  }

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}
