import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter_rss_reader/models/feed_model.dart';

class FeedService {
  Future<List<Feed>> fetchFeeds() async {
    final response =
        await http.get(Uri.parse('https://api.codetabs.com/v1/proxy/?quest=https://mybroadband.co.za/news/feed'));

    if (response.statusCode == 200) {
      try {
        final document = xml.XmlDocument.parse(response.body);

        return document.findAllElements('item').map((element) {
          final DateFormat dateFormat = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z");

          return Feed(
            pubdate: dateFormat.parse(element.findElements('pubDate').first.innerText),
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
        print('Failed to load feed: $response.body');
      }
      return [];
    }
  }
}
