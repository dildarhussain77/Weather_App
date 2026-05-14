import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app1/data/data_sources/local/storage_keys.dart';

export 'storage_keys.dart';

/// Thin wrapper over [SharedPreferences].
class LocalPrefsService {
  LocalPrefsService(this._prefs);

  final SharedPreferences _prefs;

  String? get lastCity => getString(StorageKeys.lastCity);

  Future<void> setLastCity(String city) =>
      setString(StorageKeys.lastCity, city);

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}
