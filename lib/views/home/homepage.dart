import 'dart:async';

import 'package:async/async.dart';
import 'package:camp/models/activity_model.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/home/following.dart';
import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ScrollController _controller = ScrollController();
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  bool showAll = true;
  bool isBottom = false;
  List<Datum> documentList = [];
  PostService _postService = locator<PostService>();
  final postController = StreamController<List<Datum>>.broadcast();
  @override
  void initState() {
    super.initState();
    // listener for scroll controller    postController = BehaviorSubject<List<Datum>>();

    _controller.addListener(_scrollListener);
    _fetchPosts();
  }

  _fetchPosts() {
    return this._memoizer.runOnce(() async {
      _postService.postReference.snapshots().listen((event) async {
        Stream<Activity> items = Stream.fromFuture(_postService.getPosts());

        items.listen((event) {
          documentList.addAll(event.data);
          postController.sink.add(event.data);
        });
      });
    });
  }

  Stream<List<Datum>> get postStream => postController.stream;

  _scrollListener() {
    if (_controller.position.atEdge) {
      if (_controller.position.pixels == 0) {
        isBottom = false;
        setState(() {});
      } else {
        isBottom = true;
        _fetchMore();
        setState(() {});
      }
    }
  }

  _fetchMore() async {
    // List<DocumentSnapshot> posts =
    //     await _postService.loadMorePosts(documentList[documentList.length - 1]);
    // documentList.addAll(posts);
    // postController.sink.add(documentList);
  }

  Future<bool> loadFollowing() async {
    showAll = false;
    var all = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => Following(),
      ),
    );
    showAll = all;
    return true;
  }

//Filter modalsheet
  void _showModalSheet(context, double height) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: height * 0.45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 5,
                      width: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      child: Text('Sort By'),
                    ),
                  ),
                ),
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [kYellow, kYellow.withOpacity(0.2)],
                      ),
                    ),
                    child: ListTile(
                        title: Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text('Newest',
                              style: TextStyle(color: Colors.white)),
                        ),
                        onTap: () => {}),
                  ),
                ),
                Positioned(
                  top: 110,
                  left: 20,
                  right: 0,
                  child: ListTile(title: Text('Trending'), onTap: () => {}),
                ),
                Positioned(
                  top: 160,
                  left: 20,
                  right: 0,
                  child: ListTile(title: Text('Cheapest'), onTap: () => {}),
                ),
                Positioned(
                  top: 210,
                  left: 20,
                  right: 0,
                  child:
                      ListTile(title: Text('Highest Price'), onTap: () => {}),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;
    return DrawScaffold('', LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return CustomScrollView(controller: _controller, slivers: [
        SliverList(
          delegate: SliverChildListDelegate([
            Container(
              margin: EdgeInsets.only(top: 23),
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: Container(
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'See more',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Icon(
                            FlutterIcons.arrowright_ant,
                            color: Colors.white,
                            size: 20,
                          )
                        ],
                      ),
                      width: _width * 0.3,
                    ),
                  ),
                ],
              ),
              height: _height * 0.25,
              width: _width,
              decoration: BoxDecoration(
                  color: kYellow,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30))),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 18.0, right: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            showAll = true;
                          });
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                          decoration: BoxDecoration(
                              color: showAll ? kText : Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.circle_grid_hex,
                                size: 18,
                                color: showAll ? Colors.white : kText,
                              ),
                              SizedBox(width: 10),
                              Text('All',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: showAll ? Colors.white : kText,
                                  ))
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          showAll = await loadFollowing();
                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                              color: showAll ? Colors.white : kText,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                CupertinoIcons.person_2,
                                color: showAll ? kText : Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Text('Following',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: showAll ? kText : Colors.white,
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 100,
                  ),
                  InkWell(
                    onTap: () => _showModalSheet(context, _height),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Icon(
                          CupertinoIcons.slider_horizontal_3,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 10),
          ]),
        ),
        buildStreamBuilder(),
      ]);
    }), !isBottom);
  }

  StreamBuilder<List<Datum>> buildStreamBuilder() {
    return StreamBuilder<List<Datum>>(
        stream: postStream,
        builder: (context, snapshot) {
          if (snapshot.data == null &&
              snapshot.connectionState != ConnectionState.done) {
            return SliverStaggeredGrid.countBuilder(
              crossAxisCount: 4,
              itemCount: 8,
              itemBuilder: (BuildContext context, int index) =>
                  Shimmer.fromColors(
                baseColor: Colors.grey.shade100,
                highlightColor: Colors.white,
                child: Container(
                  width: 200,
                  height: 400,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              staggeredTileBuilder: (int index) =>
                  StaggeredTile.count(2, index.isEven ? 2 : 1),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
            );
          }
          return SliverStaggeredGrid.count(
            crossAxisCount: 4,
            children: snapshot.data.map((Datum post) {
              return ItemWidget(post: post);
            }).toList(),
            staggeredTiles: snapshot.data
                .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                .toList(),
            mainAxisSpacing: 10,
          );
        });
  }

  void dispose() {
    super.dispose();
    postController.close();
  }
}
