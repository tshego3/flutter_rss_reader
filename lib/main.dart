import 'package:flutter/material.dart';
import 'package:flutter_rss_reader/viewmodels/feed_viewmodel.dart';
import 'package:flutter_rss_reader/views/feed_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FeedViewModel()),
      ],
      child: MaterialApp(
        home: FeedView(),
        themeMode: ThemeMode.system,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      ),
    );
  }
}
