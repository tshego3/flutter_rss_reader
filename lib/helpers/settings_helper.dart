import 'package:shared_preferences/shared_preferences.dart';

class SettingsHelper {
  static Future<String> loadSettingsFromPrefs(String settingname) async {
    final prefs = await SharedPreferences.getInstance();
    final setting = prefs.getString(settingname);
    if (setting != null) {
      return setting;
    }
    return '';
  }

  static Future<void> saveFeedsToPrefs(
      String settingname, String settingvalue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(settingname, settingvalue);
  }
}
