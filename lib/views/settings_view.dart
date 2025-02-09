import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/constants.dart';
import '../helpers/settings_helper.dart';
import '../providers/theme_provider.dart';

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
        title: Text(Constants.txtSettings),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(Constants.txtSystemThemee),
              value: themeProvider.useSystemTheme,
              onChanged: (value) {
                themeProvider.setUseSystemTheme(value);
              },
            ),
            if (!themeProvider.useSystemTheme)
              SwitchListTile(
                title: Text(Constants.txtDarkMode),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.setDarkMode(value);
                },
              ),
            TextField(
              controller: _rssFeedController,
              decoration: InputDecoration(
                labelText: Constants.txtRSSFeedsLink,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await SettingsHelper.saveSettingToSharedPreferences(
                    Constants.rssFeedsLink,
                    _rssFeedController.text != ''
                        ? _rssFeedController.text
                        : Constants.rssFeedsLinkValue);
              },
              child: Text(Constants.txtSave),
            ),
          ],
        ),
      ),
    );
  }
}
