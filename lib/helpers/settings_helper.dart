import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rss_model.dart';
import '../services/setting_service.dart';

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

  static Future<void> loadSettings() async {
    await SettingsHelper.saveFeedsToPrefs('rssFeedsLink',
        'https://tshego3.github.io/JSRSSFeed/assets/dist/json/feeds.json');
    List<RssModel> rssFeeds = await SettingService.fetchRssFeeds();
    await SettingsHelper.saveFeedsToPrefs('rssFeeds', jsonEncode(rssFeeds));
  }
}
