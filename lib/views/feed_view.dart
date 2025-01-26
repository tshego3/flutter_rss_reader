import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rss_reader/viewmodels/feed_viewmodel.dart';

class FeedView extends StatelessWidget {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    final feedViewModel = Provider.of<FeedViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('RSS Reader'),
      ),
      body: feedViewModel.loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: feedViewModel.feeds.length,
              itemBuilder: (context, index) {
                final feed = feedViewModel.feeds[index];
                return ListTile(
                  title: Text(feed.title),
                  subtitle: Text(feed.description),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          feedViewModel.fetchFeeds();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}
