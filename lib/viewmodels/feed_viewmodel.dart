import 'package:flutter/foundation.dart';
import '../models/feed_model.dart';
import '../services/feed_service.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedService _feedService  = FeedService();
  List<Feed>        _feeds        = [];

  Future<List<Feed>> fetchNewsFeedsAsync() async {
    _feeds    = await _feedService.fetchFeeds('https://mybroadband.co.za/news/feed');
    return _feeds;
  }

  Future<List<Feed>> fetchSportFeedsAsync() async {
    _feeds    = await _feedService.fetchFeeds('https://topauto.co.za/news/feed/');
    return _feeds;
  }

  Future<List<Feed>> fetchTechFeedsAsync() async {
    _feeds    = await _feedService.fetchFeeds('https://techcrunch.com/feed/');
    return _feeds;
  }
}
