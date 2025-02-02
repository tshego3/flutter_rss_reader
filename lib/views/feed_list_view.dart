import 'package:flutter/material.dart';
import 'package:flutter_rss_reader/models/feed_model.dart';
import 'feed_detail_view.dart';

class FeedListView extends StatelessWidget {
  const FeedListView(
      {super.key, required this.feeds, required this.searchQuery});

  final List<FeedModel> feeds;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final filteredFeeds = feeds
        .where((feed) =>
            feed.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            feed.description.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: filteredFeeds.length,
      itemBuilder: (context, index) {
        final feed = filteredFeeds[index];
        return ListTile(
          leading: Icon(Icons.rss_feed),
          title: Text(feed.title),
          subtitle: Text(feed.description),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FeedDetailView(feed: filteredFeeds[index]),
              ),
            );
          },
        );
      },
    );
  }
}
