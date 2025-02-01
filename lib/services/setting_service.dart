import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_rss_reader/models/rss_model.dart';
import 'package:http/http.dart' as http;
import '../helpers/settings_helper.dart';

class SettingService {
  static Future<List<RssModel>> fetchRssFeeds() async {
    try {
      final response = await http.get(Uri.parse(
          await SettingsHelper.loadSettingsFromPrefs('rssFeedsLink')));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((json) => RssModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        if (kDebugMode) {
          print('Failed to load RssFeeds');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return [];
    }
  }
}
