import 'dart:ui';

import 'package:camp/models/user_account.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/SearchService.dart';
import 'package:camp/views/post/widgets/color_loader_2.dart';
import 'package:camp/views/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin<SearchPage> {
  TextEditingController _searchTextController = TextEditingController();

  SearchService _searchService = locator<SearchService>();

  Future<QuerySnapshot> futureSearchResult;
  clearSearch() {
    _searchTextController.clear();
  }

  controlSearching(text) {
    Future<QuerySnapshot> allUsers = _searchService.search(text);
    setState(() {
      futureSearchResult = allUsers;
    });
  }

  AppBar searchBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: TextFormField(
        controller: _searchTextController,
        decoration: InputDecoration(
          filled: true,
          hintText: 'Search',
          border: OutlineInputBorder(),
          prefixIcon: Icon(CupertinoIcons.search),
          suffixIcon: IconButton(
              icon: Icon(CupertinoIcons.clear), onPressed: clearSearch),
        ),
        style: TextStyle(fontSize: 16, color: Colors.black),
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: searchBar(),
      body: futureSearchResult == null
          ? displayNoSearchResult()
          : resultFoundScreen(),
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
    return FutureBuilder(builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(
          child: ColorLoader2(
            color1: Colors.red,
            color2: Colors.yellow,
            color3: Colors.blue,
          ),
        );
      }
      List<SearchResult> searchResult = [];
      snapshot.data.documents.forEach((document) {
        UserAccount user = UserAccount.fromData(document);
        SearchResult result = SearchResult(user);
        searchResult.add(result);
      });
      return ListView(children: searchResult);
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class SearchResult extends StatelessWidget {
  final UserAccount user;
  SearchResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(3),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => print('tapped'),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: CachedNetworkImageProvider(user.profileUrl),
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
