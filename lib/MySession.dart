import 'package:shared_preferences/shared_preferences.dart';
class MySession {
  static MySession instance() {
    return MySession();
  }
  Future<void> saveSession(String key, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, userId);
  }

  Future<String?> getSession(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> removeSession(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}