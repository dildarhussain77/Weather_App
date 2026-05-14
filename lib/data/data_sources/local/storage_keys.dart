import 'package:shared_preferences/shared_preferences.dart';

/// Keys for [LocalPrefsService].
abstract final class StorageKeys {
  static const String lastCity = 'last_city';
}

/// Thin wrapper over [SharedPreferences].
class LocalPrefsService {
  LocalPrefsService(this._prefs);

  final SharedPreferences _prefs;

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);
}
