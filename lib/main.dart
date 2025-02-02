import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'common/constants.dart';
import 'helpers/settings_helper.dart';
import 'models/rss_model.dart';
import 'providers/theme_provider.dart';
import 'views/feed_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static const appTitle = Constants.txtAppTitle;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<List<RssModel>> _futureRssFeeds;

  @override
  void initState() {
    super.initState();
    _futureRssFeeds = SettingsHelper.fetchRssFeedsAsync(bypass: true);
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return FutureBuilder<List<RssModel>>(
      future: _futureRssFeeds,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            title: MainApp.appTitle,
            themeMode: themeProvider.currentTheme,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: Scaffold(
              body: Center(child: Text('Error:\n${snapshot.error}')),
            ),
          );
        } else if (snapshot.hasData) {
          return MaterialApp(
            title: MainApp.appTitle,
            themeMode: themeProvider.currentTheme,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: FeedView(title: MainApp.appTitle, rssFeeds: snapshot.data!),
          );
        } else {
          return MaterialApp(
            title: MainApp.appTitle,
            themeMode: themeProvider.currentTheme,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
      },
    );
  }
}
