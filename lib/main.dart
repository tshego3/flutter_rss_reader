import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'helpers/theme_provider.dart';
import 'views/feed_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const appTitle = 'RSS Reader';

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: appTitle,
      themeMode: themeProvider.currentTheme,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: FeedView(title: appTitle),
    );
  }
}
