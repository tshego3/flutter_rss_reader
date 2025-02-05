import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../helpers/settings_helper.dart';
import '../models/feed_model.dart';

class FeedDetailView extends StatelessWidget {
  const FeedDetailView({super.key, required this.feed});

  final FeedModel feed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              feed.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              DateFormat("yyyy-MM-dd HH:mm").format(feed.pubdate),
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SettingsHelper.isHtmlContent(feed.description)
                ? Html(
                    data: feed.description,
                    doNotRenderTheseTags: {'a'},
                    style: {
                      "img": Style(
                        width:
                            Width(MediaQuery.of(context).size.width, Unit.auto),
                      ),
                    },
                  )
                : Text(feed.description, style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    if (!await launchUrl(Uri.parse(feed.url),
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch ${feed.url}');
                    }
                  },
                  child: Text('Read More'),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  icon: const Icon(Icons.share),
                  onPressed: () async {
                    await Share.share(feed.url);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
