import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalStore {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
  Future<bool> remove(String key);
}

final class SharedPreferencesStore implements LocalStore {
  final SharedPreferences _preferences;

  const SharedPreferencesStore(this._preferences);

  @override
  Future<String?> getString(String key) async => _preferences.getString(key);

  @override
  Future<bool> setString(String key, String value) => _preferences.setString(key, value);

  @override
  Future<bool> remove(String key) => _preferences.remove(key);
}
