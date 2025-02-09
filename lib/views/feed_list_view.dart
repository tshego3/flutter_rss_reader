import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../common/constants.dart';
import '../helpers/settings_helper.dart';
import '../models/rss_category_model.dart';
import '../models/rss_model.dart';
import '../viewmodels/feed_viewmodel.dart';
import '../models/feed_model.dart';
import 'feed_detail_view.dart';
import 'settings_view.dart';

class FeedListView extends StatefulWidget {
  const FeedListView({super.key, required this.title, required this.rssFeeds});

  final String title;
  final List<RssModel> rssFeeds;

  @override
  State<FeedListView> createState() => _FeedListViewState();
}

class _FeedListViewState extends State<FeedListView>
    with TickerProviderStateMixin {
  RssModel _selectedFeedItem =
      RssModel(id: 0, title: '', url: '', categories: []);
  final Set<int> _expandedCategories = {};

  String _searchQuery = "";
  late Future<List<FeedModel>> _futureFeeds;
  final TextEditingController _searchController = TextEditingController();

  void _selectFeedItem(RssModel rss) {
    setState(() {
      _selectedFeedItem = rss;
      _expandedCategories.clear();

      _futureFeeds = FeedViewModel.fetchFeedsAsync(rss);
    });
    Navigator.pop(context);
  }

  void _selectCategoryFeedItem(RssCategoryModel rss, int parentId) {
    setState(() {
      _selectedFeedItem = RssModel(
        id: parentId,
        title: rss.title,
        url: rss.url,
        categories: [rss],
      );
      _expandedCategories.clear();
      _expandedCategories.add(parentId);

      _futureFeeds = FeedViewModel.fetchCategoryFeedsAsync(rss);
    });
    Navigator.pop(context);
  }

  static ListView _buildListView(
      BuildContext context, List<FeedModel> feeds, String searchQuery) {
    final filteredFeeds = feeds
        .where((feed) =>
            feed.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            feed.description.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: filteredFeeds.length,
      itemBuilder: (context, index) {
        final feed = filteredFeeds[index];
        return Card(
          child: ListTile(
            title: Text(feed.title),
            subtitle: SettingsHelper.isHtmlContent(feed.description)
                ? Html(
                    data: feed.description,
                    doNotRenderTheseTags: {'img', 'a'},
                  )
                : Text(feed.description, style: TextStyle(fontSize: 16)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FeedDetailView(feed: filteredFeeds[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedFeedItem = widget.rssFeeds[0];
    _futureFeeds = FeedViewModel.fetchFeedsAsync(_selectedFeedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: Constants.txtSearch,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<FeedModel>>(
        future: _futureFeeds,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(Constants.txtAnErrorHasOccurred),
            );
          } else if (snapshot.hasData) {
            return _buildListView(context, snapshot.data!, _searchQuery);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _futureFeeds =
                FeedViewModel.fetchFeedsAsync(_selectedFeedItem, refresh: true);
          });
        },
        child: Icon(Icons.refresh),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            ...widget.rssFeeds.map((rss) {
              if (rss.categories.isNotEmpty) {
                return ExpansionTile(
                  leading: Icon(Icons.rss_feed),
                  title: Text(rss.title),
                  initiallyExpanded: _expandedCategories.contains(rss.id),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      if (expanded) {
                        _expandedCategories.add(rss.id);
                      } else {
                        _expandedCategories.remove(rss.id);
                      }
                    });
                  },
                  children: rss.categories.map<Widget>((subItem) {
                    return ListTile(
                      leading: Icon(Icons.rss_feed),
                      title: Text(subItem.title),
                      selected:
                          _selectedFeedItem.categories.contains(subItem) ==
                              true,
                      onTap: () {
                        _selectCategoryFeedItem(subItem, rss.id);
                      },
                    );
                  }).toList(),
                );
              } else {
                return ListTile(
                  leading: Icon(Icons.rss_feed),
                  title: Text(rss.title),
                  selected: _selectedFeedItem.id == rss.id,
                  onTap: () {
                    _selectFeedItem(rss);
                  },
                );
              }
            }),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text(Constants.txtSettings),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsView(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: const Text(Constants.txtLogout),
              onTap: () async {
                await SettingsHelper.clearSettingsFromSharedPreferences();
                exit(0);
              },
            ),
          ],
        ),
      ),
    );
  }
}
