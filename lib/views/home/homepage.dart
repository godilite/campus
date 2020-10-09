import 'package:camp/service_locator.dart';
import 'package:camp/services/PostService.dart';
import 'package:camp/views/home/components/ItemWidget.dart';
import 'package:camp/views/home/following.dart';
import 'package:camp/views/layouts/drawer_scaffold.dart';
import 'package:camp/views/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  ScrollController _controller = ScrollController();
  ScrollController _gridController = ScrollController();
  bool isBottom = false;
  PostService _postService = locator<PostService>();
  @override
  void initState() {
    super.initState();
    // listener for scroll controller
    _controller.addListener(() {
      if (_controller.position.atEdge) {
        if (_controller.position.pixels == 0) {
          isBottom = false;
          setState(() {});
        } else {
          isBottom = true;
          setState(() {});
        }
      }
    });

    _gridController.addListener(() {
      if (_gridController.position.atEdge) {
        if (_gridController.position.pixels == 0) {
          isBottom = false;
          setState(() {});
        }
      }
    });
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
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50))),
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
                  top: 40,
                  left: 20,
                  right: 0,
                  child: ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text('Music'),
                      onTap: () => {}),
                ),
                Positioned(
                  top: 100,
                  left: 20,
                  right: 0,
                  child: ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text('Music'),
                      onTap: () => {}),
                ),
                Positioned(
                  top: 150,
                  left: 20,
                  right: 0,
                  child: ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text('Music'),
                      onTap: () => {}),
                ),
                Positioned(
                  top: 200,
                  left: 20,
                  right: 0,
                  child: ListTile(
                      leading: Icon(Icons.music_note),
                      title: Text('Music'),
                      onTap: () => {}),
                ),
              ],
            ),
          );
        });
  }

  bool showAll = true;
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
                            style: TextStyle(color: Colors.white),
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
              height: _height * 0.30,
              width: _width,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30))),
            ),
            SizedBox(height: 20),
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
                              color: showAll ? kGrey : Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: Row(
                            children: [
                              Icon(
                                CupertinoIcons.circle_grid_hex,
                                size: 18,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text('All', style: TextStyle(color: Colors.white))
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() async {
                            showAll = false;
                            showAll = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => Following(),
                              ),
                            );
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                              color: showAll ? Colors.white : kGrey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                CupertinoIcons.person_2,
                                size: 18,
                              ),
                              SizedBox(width: 5),
                              Text('Following',
                                  style: TextStyle(color: Colors.grey))
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            CupertinoIcons.slider_horizontal_3,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ]),
        ),
        StreamBuilder<QuerySnapshot>(
            stream: _postService.postReference.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SliverStaggeredGrid.count(
                  crossAxisCount: 4,
                  children: snapshot.data.docs.map((DocumentSnapshot post) {
                    return ItemWidget(post: post.data());
                  }).toList(),
                  staggeredTiles: snapshot.data.docs
                      .map<StaggeredTile>((_) => StaggeredTile.fit(2))
                      .toList(),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 10,
                );
              }
              return SliverList(
                  delegate: SliverChildListDelegate([Container()]));
            }),
      ]);
    }), true);
  }
}
