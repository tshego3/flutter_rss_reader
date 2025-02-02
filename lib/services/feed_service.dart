import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../common/constants.dart';
import '../helpers/settings_helper.dart';
import '../models/feed_model.dart';
import '../models/rss_model.dart';

class FeedService {
  static Future<List<FeedModel>> fetchFeeds(String url) async {
    final response =
        await http.get(Uri.parse('${Constants.rssFeedForwardProxy}$url'));

    if (response.statusCode == 200) {
      try {
        final document = xml.XmlDocument.parse(response.body);

        return document.findAllElements('item').map((element) {
          final DateFormat dateFormat =
              DateFormat("EEE, dd MMM yyyy HH:mm:ss Z");

          return FeedModel(
            pubdate: dateFormat
                .parse(element.findElements('pubDate').first.innerText),
            title: element.findElements('title').first.innerText,
            description: element.findElements('description').first.innerText,
            url: element.findElements('link').first.innerText,
          );
        }).toList()
          ..sort((a, b) => b.pubdate.compareTo(a.pubdate));
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        return [];
      }
    } else {
      if (kDebugMode) {
        String responseBody = response.body;
        print('${Constants.txtFailedToLoadFeeds} \n$responseBody');
      }
      return [];
    }
  }

  static Future<List<RssModel>> fetchRssFeeds() async {
    try {
      final response = await http.get(Uri.parse(
          await SettingsHelper.loadSettingFromSharedPreferences(
              Constants.rssFeedsLink)));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((json) => RssModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        if (kDebugMode) {
          print(Constants.txtFailedToLoadFeeds);
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
