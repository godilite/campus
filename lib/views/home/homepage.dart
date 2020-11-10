import 'dart:async';

import 'package:async/async.dart';
import 'package:camp/models/activity_model.dart';
import 'package:camp/service_locator.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/home/following.dart';
import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:camp/views/post/widgets/color_loader_2.dart';
import 'package:camp/views/sponsored/sponsored.dart';
import 'package:camp/views/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ScrollController _controller = ScrollController();
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  bool showAll = true;
  bool isBottom = false;
  List<Datum> documentList = [];
  int currentItem = 0;
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

  void scrollTo() {
    itemScrollController.scrollTo(
        index: currentItem + 1,
        duration: Duration(seconds: 2),
        curve: Curves.easeInOutCubic);
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
              height: _height * 0.30,
              width: _width,
              decoration: BoxDecoration(
                color: kYellow,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: viewportConstraints.maxWidth * 0.9,
                    child: ScrollablePositionedList.builder(
                        itemScrollController: itemScrollController,
                        itemPositionsListener: itemPositionsListener,
                        scrollDirection: Axis.horizontal,
                        itemCount: 29,
                        itemBuilder: (context, index) {
                          currentItem = index;
                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Sponsored(),
                              ),
                            ),
                            child: Container(
                              height: viewportConstraints.maxHeight * 0.20,
                              width: viewportConstraints.maxWidth * 0.56,
                              child: Stack(
                                fit: StackFit.passthrough,
                                children: [
                                  Positioned(
                                    top: 35,
                                    width: viewportConstraints.maxWidth * 0.56,
                                    height:
                                        viewportConstraints.maxHeight * 0.20,
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      elevation: 2,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    width: viewportConstraints.maxWidth * 0.5,
                                    child: Text(
                                      'New Shoes pF KAS S JAS LA skdf kdf kjsd ',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
                  SizedBox(
                    width: viewportConstraints.maxWidth * 0.1,
                    height: viewportConstraints.maxWidth * 0.1,
                    child: InkWell(
                      onTap: () => scrollTo(),
                      child: Card(
                        shape: CircleBorder(),
                        elevation: 2,
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey.shade500,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
            return SliverToBoxAdapter(
              child: Center(child: ColorLoader2()),
            );
          }
          return SliverStaggeredGrid.count(
            crossAxisCount: 4,
            children: snapshot.data.map((Datum post) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ItemWidget(post: post),
              );
            }).toList(),
            staggeredTiles: snapshot.data
                .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                .toList(),
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          );
        });
  }

  void dispose() {
    super.dispose();
    postController.close();
  }
}
