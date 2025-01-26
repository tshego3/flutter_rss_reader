import 'package:flutter/foundation.dart';
import 'package:flutter_rss_reader/models/feed_model.dart';
import 'package:flutter_rss_reader/services/feed_service.dart';

class FeedViewModel extends ChangeNotifier {
  final FeedService _feedService  = FeedService();
  List<Feed>        _feeds        = [];
  bool              _loading      = false;

  List<Feed>        get feeds     => _feeds;
  bool              get loading   => _loading;

  FeedViewModel() {
    fetchFeeds();
  }

  Future<void> fetchFeeds() async {
    _loading = true;
    notifyListeners();
    _feeds    = await _feedService.fetchFeeds();
    _loading  = false;
    notifyListeners();
  }
}
