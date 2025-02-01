import 'dart:io';
import 'package:flutter/material.dart';
import '../viewmodels/feed_viewmodel.dart';
import '../models/feed_model.dart';
import 'feed_detail_view.dart';

class FeedView extends StatefulWidget {
  const FeedView({super.key, required this.title});

  final String title;

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late Future<List<Feed>> futureFeeds;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    futureFeeds = FeedViewModel().fetchNewsFeedsAsync();
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
          futureFeeds = FeedViewModel().fetchNewsFeedsAsync();
          break;
        case 1:
          futureFeeds = FeedViewModel().fetchSportFeedsAsync();
          break;
        case 2:
          futureFeeds = FeedViewModel().fetchTechFeedsAsync();
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
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
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
        ),
      ),
      body: FutureBuilder<List<Feed>>(
        future: futureFeeds,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return Center(
              child: _widgetOptions(
                  context, snapshot.data!, _searchQuery)[_selectedIndex],
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
                futureFeeds = FeedViewModel().fetchNewsFeedsAsync(bypass: true);
                break;
              case 1:
                futureFeeds =
                    FeedViewModel().fetchSportFeedsAsync(bypass: true);
                break;
              case 2:
                futureFeeds = FeedViewModel().fetchTechFeedsAsync(bypass: true);
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
