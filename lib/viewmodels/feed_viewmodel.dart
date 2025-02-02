import 'dart:convert';
import '../common/constants.dart';
import '../helpers/settings_helper.dart';
import '../models/feed_model.dart';
import '../models/rss_category_model.dart';
import '../models/rss_model.dart';
import '../services/feed_service.dart';

class FeedViewModel {
  static Future<List<FeedModel>> _loadFeedFromSharedPreferences(
      String feedname) async {
    final json =
        await SettingsHelper.loadSettingFromSharedPreferences(feedname);
    if (json != '') {
      List<dynamic> feed = jsonDecode(json) as List<dynamic>;
      return feed
          .map((json) => FeedModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static Future<void> _saveFeedToSharedPreferences(
      String feedname, List<FeedModel> feeds) async {
    await SettingsHelper.saveSettingToSharedPreferences(
        feedname, jsonEncode(feeds));
  }

  static Future<List<FeedModel>> fetchFeedsAsync(RssModel rss,
      {bool bypass = false}) async {
    List<FeedModel> feeds =
        await _loadFeedFromSharedPreferences('${Constants.rssFeedId}${rss.id}');
    if (feeds.isEmpty || bypass == true) {
      feeds = await FeedService.fetchFeeds(rss.url);
      await _saveFeedToSharedPreferences(
          '${Constants.rssFeedId}${rss.id}', feeds);
    }
    return feeds;
  }

  static Future<List<FeedModel>> fetchCategoryFeedsAsync(
      RssCategoryModel rssCategory,
      {bool bypass = false}) async {
    List<FeedModel> feeds = await _loadFeedFromSharedPreferences(
        '${Constants.rssFeedCategoryId}${rssCategory.id}');
    if (feeds.isEmpty || bypass == true) {
      feeds = await FeedService.fetchFeeds(rssCategory.url);
      await _saveFeedToSharedPreferences(
          '${Constants.rssFeedCategoryId}${rssCategory.id}', feeds);
    }
    return feeds;
  }
}
