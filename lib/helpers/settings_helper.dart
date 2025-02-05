import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constants.dart';
import '../models/rss_model.dart';
import '../services/feed_service.dart';

class SettingsHelper {
  static bool isHtmlContent(String input) {
    final htmlPattern = RegExp(r'<[^>]+>');
    return htmlPattern.hasMatch(input);
  }

  static Future<void> clearSettingsFromSharedPreferences() async {
    final sp = await SharedPreferences.getInstance();
    sp.clear();
  }

  static Future<String> loadSettingFromSharedPreferences(
      String settingname) async {
    final sp = await SharedPreferences.getInstance();
    final setting = sp.getString(settingname);
    if (setting != null) {
      return setting;
    }
    return '';
  }

  static Future<void> saveSettingToSharedPreferences(
      String settingname, String settingvalue) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(settingname, settingvalue);
  }

  static Future<List<RssModel>> _loadRssFeedsFromSharedPreferences() async {
    final json = await SettingsHelper.loadSettingFromSharedPreferences(
        Constants.rssFeeds);
    if (json != '') {
      List<dynamic> rssFeeds = jsonDecode(json) as List<dynamic>;
      return rssFeeds
          .map((json) => RssModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<void> _saveRssFeedsToSharedPreferences(
      List<RssModel> feeds) async {
    await SettingsHelper.saveSettingToSharedPreferences(
        Constants.rssFeeds, jsonEncode(feeds));
  }

  static Future<void> loadSettingsFromSharedPreferences() async {
    await SettingsHelper.saveSettingToSharedPreferences(
        Constants.rssFeedsLink, Constants.rssFeedsLinkValue);
    List<RssModel> rssFeeds = await FeedService.fetchRssFeeds();
    await SettingsHelper.saveSettingToSharedPreferences(
        Constants.rssFeeds, jsonEncode(rssFeeds));
  }

  static Future<List<RssModel>> fetchRssFeedsAsync(
      {bool bypass = false}) async {
    await loadSettingsFromSharedPreferences();
    List<RssModel> rssFeeds = await _loadRssFeedsFromSharedPreferences();
    if (rssFeeds.isEmpty || bypass == true) {
      rssFeeds = await FeedService.fetchRssFeeds();
      await _saveRssFeedsToSharedPreferences(rssFeeds);
    }
    return rssFeeds;
  }
}
