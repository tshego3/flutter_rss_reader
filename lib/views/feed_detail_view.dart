import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/feed_model.dart';

class FeedDetailView extends StatelessWidget {
  const FeedDetailView({super.key, required this.feed});

  final FeedModel feed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(feed.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(DateFormat("yyyy-MM-dd HH:mm").format(feed.pubdate),
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 8),
            Text(feed.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (!await launchUrl(Uri.parse(feed.url))) {
                  throw Exception('Could not launch ${feed.url}');
                }
              },
              child: Text('Read More'),
            ),
          ],
        ),
      ),
    );
  }
}
