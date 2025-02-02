import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../common/constants.dart';
import '../helpers/settings_helper.dart';
import '../models/rss_model.dart';
import '../viewmodels/feed_viewmodel.dart';
import '../models/feed_model.dart';
import 'feed_detail_view.dart';
import 'settings_view.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key, required this.title, required this.rssFeeds});

  final String title;
  final List<RssModel> rssFeeds;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchQuery = "";
  late TabController _tabController;
  late Future<List<FeedModel>> _futureFeeds;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureFeeds = FeedViewModel.fetchFeedsAsync(widget.rssFeeds[0]);
    _tabController = TabController(length: 3, vsync: this);
  }

  static List<Widget> _widgetOptions(
          BuildContext context, List<FeedModel> feeds, String searchQuery) =>
      <Widget>[
        _buildListView(context, feeds, searchQuery),
        _buildListView(context, feeds, searchQuery),
        _buildListView(context, feeds, searchQuery),
      ];

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
        return ListTile(
          leading: Icon(Icons.rss_feed),
          title: Text(feed.title),
          subtitle: Text(feed.description),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    FeedDetailView(feed: filteredFeeds[index]),
              ),
            );
          },
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (_selectedIndex) {
        case 0:
          _futureFeeds = FeedViewModel.fetchFeedsAsync(widget.rssFeeds[0]);
          break;
        case 1:
          _futureFeeds = FeedViewModel.fetchFeedsAsync(widget.rssFeeds[1]);
          break;
        case 2:
          _futureFeeds = FeedViewModel.fetchFeedsAsync(widget.rssFeeds[2]);
          break;
      }
    });
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
          preferredSize: Size.fromHeight(kToolbarHeight + kTextTabBarHeight),
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
              TabBar(
                controller: _tabController,
                tabs: <Tab>[
                  Tab(text: widget.rssFeeds[0].title),
                  Tab(text: widget.rssFeeds[1].title),
                  Tab(text: widget.rssFeeds[2].title),
                ],
                onTap: _onItemTapped,
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
            return TabBarView(
              controller: _tabController,
              children: _widgetOptions(context, snapshot.data!, _searchQuery),
            );
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
            switch (_selectedIndex) {
              case 0:
                _futureFeeds = FeedViewModel.fetchFeedsAsync(widget.rssFeeds[0],
                    bypass: true);
                break;
              case 1:
                _futureFeeds = FeedViewModel.fetchFeedsAsync(widget.rssFeeds[1],
                    bypass: true);
                break;
              case 2:
                _futureFeeds = FeedViewModel.fetchFeedsAsync(widget.rssFeeds[2],
                    bypass: true);
                break;
            }
          });
        },
        child: Icon(Icons.refresh),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.newspaper),
              title: Text(widget.rssFeeds[0].title),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.sports_score),
              title: Text(widget.rssFeeds[1].title),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.computer),
              title: Text(widget.rssFeeds[2].title),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
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
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: widget.rssFeeds[0].title,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_score),
            label: widget.rssFeeds[1].title,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: widget.rssFeeds[2].title,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
