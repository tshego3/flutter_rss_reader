import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rss_reader/views/settings_view.dart';
import '../helpers/settings_helper.dart';
import '../viewmodels/feed_viewmodel.dart';
import '../models/feed_model.dart';
import 'feed_detail_view.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key, required this.title});

  final String title;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String _searchQuery = "";
  late TabController _tabController;
  late Future<List<Feed>> _futureFeeds;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SettingsHelper.loadSettings();
    _futureFeeds = FeedViewModel().fetchNewsFeedsAsync();
    _tabController = TabController(length: 3, vsync: this);
  }

  static List<Widget> _widgetOptions(
          BuildContext context, List<Feed> feeds, String searchQuery) =>
      <Widget>[
        _buildListView(context, feeds, searchQuery),
        _buildListView(context, feeds, searchQuery),
        _buildListView(context, feeds, searchQuery),
      ];

  static ListView _buildListView(
      BuildContext context, List<Feed> feeds, String searchQuery) {
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
          _futureFeeds = FeedViewModel().fetchNewsFeedsAsync();
          break;
        case 1:
          _futureFeeds = FeedViewModel().fetchSportFeedsAsync();
          break;
        case 2:
          _futureFeeds = FeedViewModel().fetchTechFeedsAsync();
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
                    hintText: 'Search...',
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
                tabs: const <Tab>[
                  Tab(text: 'News'),
                  Tab(text: 'Sport'),
                  Tab(text: 'Tech'),
                ],
                onTap: _onItemTapped,
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Feed>>(
        future: _futureFeeds,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
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
                _futureFeeds =
                    FeedViewModel().fetchNewsFeedsAsync(bypass: true);
                break;
              case 1:
                _futureFeeds =
                    FeedViewModel().fetchSportFeedsAsync(bypass: true);
                break;
              case 2:
                _futureFeeds =
                    FeedViewModel().fetchTechFeedsAsync(bypass: true);
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
              title: const Text('News'),
              selected: _selectedIndex == 0,
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.sports_score),
              title: const Text('Sport'),
              selected: _selectedIndex == 1,
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.computer),
              title: const Text('Tech'),
              selected: _selectedIndex == 2,
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('Settings'),
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
              title: const Text('Logout'),
              onTap: () async {
                await FeedViewModel().clearSharedPreferencesAsync();
                exit(0);
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_score),
            label: 'Sport',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: 'Tech',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
