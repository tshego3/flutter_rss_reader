import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/settings_helper.dart';
import '../helpers/theme_provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _rssFeedController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('System Theme'),
              value: themeProvider.useSystemTheme,
              onChanged: (value) {
                themeProvider.setUseSystemTheme(value);
              },
            ),
            if (!themeProvider.useSystemTheme)
              SwitchListTile(
                title: Text('Light/Dark Theme'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.setDarkMode(value);
                },
              ),
            TextField(
              controller: _rssFeedController,
              decoration: InputDecoration(
                labelText: 'RSS Feeds Link',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await SettingsHelper.saveFeedsToPrefs(
                    'rssFeeds',
                    _rssFeedController.text != ''
                        ? _rssFeedController.text
                        : 'https://tshego3.github.io/JSRSSFeed/assets/dist/json/feeds.json');
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
