import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/feed_model.dart';
import '../services/feed_service.dart';

class FeedViewModel {
  final FeedService _feedService = FeedService();
  List<Feed> _feeds = [];

  Future<List<Feed>> _loadFeedsFromPrefs(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final feedsJson = prefs.getString(category);
    if (feedsJson != null) {
      final List<dynamic> decoded = json.decode(feedsJson);
      return decoded.map((e) => Feed.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _saveFeedsToPrefs(String category, List<Feed> feeds) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> feedJson =
        feeds.map((feed) => feed.toJson()).toList();
    await prefs.setString(category, json.encode(feedJson));
  }

  Future<List<Feed>> fetchNewsFeedsAsync({bool bypass = false}) async {
    _feeds = await _loadFeedsFromPrefs('news');
    if (_feeds.isEmpty || bypass == true) {
      _feeds =
          await _feedService.fetchFeeds('https://mybroadband.co.za/news/feed');
      await _saveFeedsToPrefs('news', _feeds);
    }
    return _feeds;
  }

  Future<List<Feed>> fetchSportFeedsAsync({bool bypass = false}) async {
    _feeds = await _loadFeedsFromPrefs('sport');
    if (_feeds.isEmpty || bypass == true) {
      _feeds =
          await _feedService.fetchFeeds('https://topauto.co.za/news/feed/');
      await _saveFeedsToPrefs('sport', _feeds);
    }
    return _feeds;
  }

  Future<List<Feed>> fetchTechFeedsAsync({bool bypass = false}) async {
    _feeds = await _loadFeedsFromPrefs('tech');
    if (_feeds.isEmpty || bypass == true) {
      _feeds = await _feedService.fetchFeeds('https://techcrunch.com/feed/');
      await _saveFeedsToPrefs('tech', _feeds);
    }
    return _feeds;
  }

  Future<void> clearSharedPreferencesAsync() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
