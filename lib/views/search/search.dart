import 'dart:ui';

import 'package:camp/models/post_model.dart';
import 'package:camp/models/user_account.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/SearchService.dart';
import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/post/widgets/color_loader_2.dart';
import 'package:camp/views/profile/profile.dart';
import 'package:camp/views/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController _searchTextController = TextEditingController();
  TabController _tabController;
  SearchService _searchService = locator<SearchService>();

  Future<Stream<List<QuerySnapshot>>> futureSearchResult;
  List<SearchResult> searchResult = [];

  List<ItemWidget> postResult = [];

  clearSearch() {
    _searchTextController.clear();
  }

  controlSearching() async {
    if (_searchTextController.text.isNotEmpty) {
      var allUsers = _searchService.search(_searchTextController.text);

      setState(() {
        postResult.clear();
        searchResult.clear();
        futureSearchResult = allUsers;
      });
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Positioned(
                top: 15.0,
                bottom: 0,
                left: 0,
                right: 0,
                child: buildSearchBar(context, constraints),
              ),
              Positioned(
                top: 70,
                bottom: 0,
                left: 0,
                right: 0,
                child: futureSearchResult == null
                    ? displayNoSearchResult()
                    : resultFoundScreen(),
              )
            ],
          ),
        );
      }),
    );
  }

  Container buildSearchBar(BuildContext context, BoxConstraints constraints) {
    return Container(
      height: 100,
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_ios)),
              SizedBox(
                width: constraints.maxWidth * 0.85,
                height: constraints.maxHeight * 0.08,
                child: TextFormField(
                  cursorColor: kYellow,
                  controller: _searchTextController,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Search',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    prefixIcon: Icon(CupertinoIcons.search),
                    suffixIcon: IconButton(
                        icon: Icon(CupertinoIcons.clear),
                        onPressed: clearSearch),
                  ),
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  onEditingComplete: controlSearching,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container displayNoSearchResult() {
//    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Icon(
              Icons.search_off,
              size: 50,
            ),
            Text(
              'No result found',
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  resultFoundScreen() {
    return FutureBuilder(
        future: futureSearchResult,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: ColorLoader2(
                color1: Colors.red,
                color2: Colors.yellow,
                color3: Colors.blue,
              ),
            );
          }
          snapshot.data.forEach((document) {
            document[1].documents.forEach((post) {
              PostModel posts = PostModel.fromData(post);
              ItemWidget postList = ItemWidget(post: posts);
              setState(() {
                postResult.add(postList);
              });
            });
            document[0].documents.forEach((d) {
              UserAccount users = UserAccount.fromData(d);
              SearchResult result = SearchResult(users);
              searchResult.add(result);
            });
            _tabController.animateTo(0);
          });
          return Column(
            children: [_tabBarSection()],
          );
        });
  }

  _tabBar() {
    return PreferredSize(
      preferredSize: Size(200.0, 60.0),
      child: Container(
        height: 40,
        margin: EdgeInsets.only(bottom: 20),
        child: TabBar(
            indicatorPadding: EdgeInsets.symmetric(horizontal: 40),
            controller: _tabController,
            unselectedLabelColor: kText,
            labelColor: kYellow,
            indicatorColor: kYellow,
            tabs: [
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(CupertinoIcons.square_favorites),
                          Text("Posts"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Tab(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(CupertinoIcons.person_2_fill),
                          Text("People"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  _tabBarView() {
    _tabController.addListener(() {
      setState(() {});
    });
    return Container(
      height: MediaQuery.of(context).size.height * 0.774,
      child: TabBarView(children: [
        Container(
          child: StaggeredGridView.count(
            crossAxisCount: 4,
            children: postResult,
            staggeredTiles: postResult
                .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                .toList(),
            mainAxisSpacing: 20,
          ),
        ),
        Container(
          child: ListView(children: searchResult),
        ),
      ], controller: _tabController),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _tabBarSection() {
    return DefaultTabController(
      length: 2,
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[_tabBar(), _tabBarView()]),
    );
  }
}

class SearchResult extends StatelessWidget {
  final UserAccount user;
  SearchResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 3),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ProfilePage(
                  user: user,
                ),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: user.profileUrl != null
                    ? CachedNetworkImageProvider(user.profileUrl)
                    : AssetImage('assets/icons8-male-user-100.png'),
              ),
              title: Text(
                user.name,
                style: TextStyle(color: kText, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(user.username),
            ),
          ),
        ],
      ),
    );
  }
}
