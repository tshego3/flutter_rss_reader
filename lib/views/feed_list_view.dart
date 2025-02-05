import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../common/constants.dart';
import '../helpers/settings_helper.dart';
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
  int _selectedIndex = 0;
  int _selectedIndexTabBar = 0;
  int _selectedIndexBottomNavBar = 0;

  String _searchQuery = "";
  late TabController _tabController;
  late Future<List<FeedModel>> _futureFeeds;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureFeeds = FeedViewModel.fetchFeedsAsync(widget.rssFeeds[0]);
    _tabController = TabController(
        length: widget.rssFeeds[0].categories.isEmpty
            ? 1
            : widget.rssFeeds[0].categories.length,
        vsync: this);
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (widget.rssFeeds[_selectedIndex].categories.isEmpty) {
        _futureFeeds =
            FeedViewModel.fetchFeedsAsync(widget.rssFeeds[_selectedIndex]);
      } else {
        _futureFeeds = FeedViewModel.fetchCategoryFeedsAsync(
            widget.rssFeeds[_selectedIndex].categories[_selectedIndexTabBar]);
        _tabController.dispose();
        _tabController = TabController(
            length: widget.rssFeeds[_selectedIndex].categories.length,
            vsync: this);
      }
    });
  }

  void _onItemTappedTabBar(int index) {
    setState(() {
      _selectedIndexTabBar = index;
      _futureFeeds = FeedViewModel.fetchCategoryFeedsAsync(
          widget.rssFeeds[_selectedIndex].categories[_selectedIndexTabBar]);
      _tabController.dispose();
      _tabController = TabController(
          length: widget.rssFeeds[_selectedIndex].categories.length,
          vsync: this);
    });
  }

  void _onItemTappedBottomNavBar(int index) {
    setState(() {
      _selectedIndexBottomNavBar = index;
      switch (_selectedIndexBottomNavBar) {
        case 0:
          if (widget.rssFeeds[_selectedIndex].categories.isEmpty) {
            _futureFeeds =
                FeedViewModel.fetchFeedsAsync(widget.rssFeeds[_selectedIndex]);
          } else {
            _futureFeeds = FeedViewModel.fetchCategoryFeedsAsync(widget
                .rssFeeds[_selectedIndex].categories[_selectedIndexTabBar]);
            _tabController.dispose();
            _tabController = TabController(
                length: widget.rssFeeds[_selectedIndex].categories.length,
                vsync: this);
          }
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsView(),
            ),
          );
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
              widget.rssFeeds[_selectedIndex].categories.isEmpty
                  ? Container()
                  : TabBar(
                      controller: _tabController,
                      tabs: widget.rssFeeds[_selectedIndex].categories
                          .map((category) => Tab(text: category.title))
                          .toList(),
                      onTap: _onItemTappedTabBar,
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
            return widget.rssFeeds[_selectedIndex].categories.isEmpty
                ? _buildListView(context, snapshot.data!, _searchQuery)
                : TabBarView(
                    controller: _tabController,
                    children: widget.rssFeeds[_selectedIndex].categories
                        .map((category) => _buildListView(
                            context, snapshot.data!, _searchQuery))
                        .toList(),
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
            if (widget.rssFeeds[_selectedIndex].categories.isEmpty) {
              _futureFeeds = FeedViewModel.fetchFeedsAsync(
                  widget.rssFeeds[_selectedIndex],
                  bypass: true);
            } else {
              _futureFeeds = FeedViewModel.fetchCategoryFeedsAsync(
                  widget.rssFeeds[_selectedIndex]
                      .categories[_selectedIndexTabBar],
                  bypass: true);
            }
          });
        },
        child: Icon(Icons.refresh),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            ...widget.rssFeeds.map(
              (rss) => ListTile(
                leading: Icon(Icons.rss_feed),
                title: Text(rss.title),
                selected: _selectedIndex == widget.rssFeeds.indexOf(rss),
                onTap: () {
                  _onItemTapped(widget.rssFeeds.indexOf(rss));
                  Navigator.pop(context);
                },
              ),
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
            label: Constants.txtNews,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: Constants.txtSettings,
          ),
        ],
        currentIndex: _selectedIndexBottomNavBar,
        onTap: _onItemTappedBottomNavBar,
      ),
    );
  }
}
