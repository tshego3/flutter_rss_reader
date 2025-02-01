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

  @override
  void initState() {
    super.initState();
    futureFeeds = FeedViewModel().fetchNewsFeedsAsync();
  }

  static List<Widget> _widgetOptions(BuildContext context, List<Feed> feeds) =>
      <Widget>[
        _buildListView(context, feeds),
        _buildListView(context, feeds),
        _buildListView(context, feeds),
      ];

  static ListView _buildListView(BuildContext context, List<Feed> feeds) {
    return ListView.builder(
      itemCount: feeds.length,
      itemBuilder: (context, index) {
        final feed = feeds[index];
        return ListTile(
          leading: Icon(Icons.rss_feed),
          title: Text(feed.title),
          subtitle: Text(feed.description),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FeedDetailView(feed: feeds[index]),
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
              child: _widgetOptions(context, snapshot.data!)[_selectedIndex],
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
