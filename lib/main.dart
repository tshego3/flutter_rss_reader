import 'package:flutter/material.dart';
import 'views/feed_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const appTitle = 'RSS Reader';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: FeedView(title: appTitle),
    );
  }
}
