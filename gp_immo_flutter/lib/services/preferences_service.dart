import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyNavIndex = 'nav_index';
  static const String _keyShowOwner = 'show_owner';
  static const String _keyCurrentUserId = 'current_user_id';

  Future<int> loadNavIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyNavIndex) ?? 0;
  }

  Future<void> saveNavIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyNavIndex, index);
  }

  Future<bool> loadShowOwner() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowOwner) ?? true;
  }

  Future<void> saveShowOwner(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowOwner, value);
  }

  Future<String?> loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUserId);
  }

  Future<void> saveCurrentUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentUserId, userId);
  }

  Future<void> clearCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCurrentUserId);
  }
}
